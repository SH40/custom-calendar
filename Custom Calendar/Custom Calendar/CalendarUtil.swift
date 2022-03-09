
import Foundation

class CalendarUtil {
    
    struct CalenDay {
        let year: String
        let month: String
        let day: String
        let isinMonth: Bool
        
        //DateFormat: "yyyy-MM-dd"
        init(ymd: String, isinMonth: Bool) {
            self.year  = ymd.subStringC(startIndex: 0, endIndex: 3)
            self.month = ymd.subStringC(startIndex: 5, endIndex: 6)
            self.day   = ymd.subStringC(startIndex: 8, endIndex: 9)
            self.isinMonth = isinMonth
        }
    }
    
    var stanYearMonth: Observable<String> = Observable("")
    var datas: Observable<[CalenDay]> = Observable([CalenDay]())
    
    func reload() {
        let curYearMonth = getCurYearMonth()
        self.stanYearMonth.value = "\(curYearMonth.year)-\(curYearMonth.month)"
        self.datas.value = getDays(yearMonth: self.stanYearMonth.value)
    }
    
    func changeMonth(addingnMonth: Int) {
        self.stanYearMonth.value = getAddingMonthString(stanDateStr: stanYearMonth.value, addingnMonth: addingnMonth)
        self.datas.value = getDays(yearMonth: stanYearMonth.value)
    }
    
    
    private func getDays(yearMonth: String) -> [CalenDay]{
        
        var numOfDaysInMonth       = [31,28,31,30,31,30,31,31,30,31,30,31]
        var selectYear: Int        = 0
        var selectMonthIndex: Int  = 0
        var firstWeekDayOfMonth    = 0 //(Sunday-Saturday 1-7)
        
        if yearMonth.count == 7 {
            selectYear       = Int(yearMonth.subStringC(startIndex: 0, endIndex: 3)) ?? Calendar.current.component(.year,  from: Date())
            selectMonthIndex = Int(yearMonth.subStringC(startIndex: 5, endIndex: 6)) ?? Calendar.current.component(.month, from: Date())
        }else{
            selectYear       = Calendar.current.component(.year,  from: Date())
            selectMonthIndex = Calendar.current.component(.month, from: Date())
        }
        
        let preYearMonth = getAddingMonthString(stanDateStr: "\(selectYear)-\(selectMonthIndex)", addingnMonth: -1)
        let nextYearMonth = getAddingMonthString(stanDateStr: "\(selectYear)-\(selectMonthIndex)", addingnMonth: 1)
        
        firstWeekDayOfMonth = getWeekbyDateString(date: "\(selectYear)-\(selectMonthIndex)-01")

        //윤년의 2월달 일자 계산
        if selectMonthIndex == 2 && selectYear%4 == 0 && ( selectYear%100 != 0 || selectYear%400 == 0) {
            numOfDaysInMonth[1] = 29
        }
        
        let maxDayinMonth = numOfDaysInMonth[selectMonthIndex-1]
        
        var cals = [CalenDay]()
        for i in 0..<maxDayinMonth {
            cals.append(CalenDay(ymd: "\(yearMonth)-\(String.init(format: "%02d", i+1))", isinMonth: true))
        }
        
        //매월 첫일 (01일)이 어느 요일부터 시작하는 지에 따라 (배열에 첫 부분 공백을 줌)
        //ex) 화요일이면 2칸을 띄운다
        let maxDayinMonthPre  = numOfDaysInMonth[ (selectMonthIndex-2 < 0) ? numOfDaysInMonth.count - 1 : selectMonthIndex-2]
        
        for i in 0 ..< firstWeekDayOfMonth-1 {
            cals.insert(CalenDay(ymd: "\(preYearMonth)-\(String.init(format: "%02d", maxDayinMonthPre-i))", isinMonth: false), at: 0)
        }
        
        //이 부분은 뒤쪽 button
        let Addcount = (firstWeekDayOfMonth - 1 + maxDayinMonth) % 7
        
        if (1...6) ~= Addcount {
            for i in 0..<(7 - Addcount) {
                cals.append(CalenDay(ymd: "\(nextYearMonth)-\(String.init(format: "%02d", i+1))", isinMonth: false))
            }
        }
        
        var addcountBottomLine = Addcount
        if cals.count / 7 < 6 {
            
            if addcountBottomLine == 0 {
                addcountBottomLine = 0
            }else{
                addcountBottomLine = 7 - addcountBottomLine
            }
            
            for i in addcountBottomLine..<(addcountBottomLine + 7) {
                cals.append(CalenDay(ymd: "\(nextYearMonth)-\(String.init(format: "%02d", i+1))", isinMonth: false))
            }
        }
        
        return cals
    }


    private func getWeekbyDateString(date: String) -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date = dateFormatter.date(from: date)!
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday
    }

    private func getAddingMonthString(stanDateStr: String, addingnMonth: Int) -> String {
        let today = dateFromCustom(string: stanDateStr)
        let date = Calendar.current.date(byAdding: .month, value: addingnMonth, to: today)!
        return StringFrom(date: date)
    }

    private func dateFromCustom(string: String) -> Date {
        return getDateFormat().date(from: string) ?? Date()
    }

    private func StringFrom(date: Date) -> String{
        return getDateFormat().string(from: date)
    }

    private func getDateFormat() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM" // "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }

    private func getCurYearMonth() -> (year: String, month: String, day: String) {
        let nYear  = Calendar.current.component(.year,  from: Date())
        let nMonth = Calendar.current.component(.month, from: Date())
        let nDay   = Calendar.current.component(.day,   from: Date())
        
        let year   = String.init(format: "%04d", nYear)
        let month  = String.init(format: "%02d", nMonth)
        let day    = String.init(format: "%02d", nDay)
        
        return (year: year, month: month, day: day)
    }
}

extension String{
    func subStringC(startIndex: Int, endIndex: Int) -> String {
        let end = (endIndex - self.count) + 1
        let indexStartOfText = self.index(self.startIndex, offsetBy: startIndex)
        let indexEndOfText = self.index(self.endIndex, offsetBy: end)
        let substring = self[indexStartOfText..<indexEndOfText]
        return String(substring)
    }
}

class Observable<T> {
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}

