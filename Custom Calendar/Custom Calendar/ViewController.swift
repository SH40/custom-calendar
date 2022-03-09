
import UIKit

class ViewController: UIViewController {
    
    let calUtil = CalendarUtil()
    var nsconst42: NSLayoutConstraint?
    var nsconst35: NSLayoutConstraint?
    let maxCnt: Int = 42
    let minCnt: Int = 35
    
    let lblDate: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.font = UIFont.systemFont(ofSize: 20)
        return lbl
    }()
    
    lazy var preBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.setTitle("< previous", for: .normal)
        btn.contentHorizontalAlignment = .leading
        return btn
    }()
    
    lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        btn.setTitleColor(UIColor.systemBlue, for: .normal)
        btn.setTitle("next >", for: .normal)
        btn.contentHorizontalAlignment = .trailing
        return btn
    }()
    
    let dayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.1)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let lblWeeks: [UILabel] = {
        let weekHan = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var lbls = [UILabel]()
        for i in 0..<weekHan.count {
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.textAlignment = .center
            lbl.backgroundColor = UIColor.clear
            lbl.text = weekHan[i]
            lbl.textColor = UIColor.systemBlue
            lbls.append(lbl)
        }
        return lbls
    }()
    
    lazy var lblDays: [UILabel] = {
        var lbls = [UILabel]()
        for _ in 0..<maxCnt {
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.textAlignment = .center
            lbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            lbls.append(lbl)
        }
        return lbls
    }()

    @objc func click(_ sender: UIButton) {
        
        if sender === preBtn {
            calUtil.changeMonth(addingnMonth: -1)

        }else if sender === nextBtn {
            calUtil.changeMonth(addingnMonth: 1)
        }
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        
        view.addSubview(lblDate)
        view.addSubview(dayView)
        view.addSubview(preBtn)
        view.addSubview(nextBtn)
        
        NSLayoutConstraint.activate([
            lblDate.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            lblDate.widthAnchor.constraint(equalTo: dayView.widthAnchor, multiplier: 1/3),
            lblDate.centerXAnchor.constraint(equalTo: dayView.centerXAnchor),
            lblDate.heightAnchor.constraint(equalToConstant: 60),
            
            preBtn.centerYAnchor.constraint(equalTo: lblDate.centerYAnchor),
            preBtn.leadingAnchor.constraint(equalTo: dayView.leadingAnchor),
            preBtn.widthAnchor.constraint(equalTo: dayView.widthAnchor, multiplier: 1/3),
            
            nextBtn.centerYAnchor.constraint(equalTo: lblDate.centerYAnchor),
            nextBtn.trailingAnchor.constraint(equalTo: dayView.trailingAnchor),
            nextBtn.widthAnchor.constraint(equalTo: dayView.widthAnchor, multiplier: 1/3),
            
            dayView.topAnchor.constraint(equalTo: lblDate.bottomAnchor),
            dayView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            dayView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
        
        
        for i in 0..<lblWeeks.count {
            
            dayView.addSubview(lblWeeks[i])
            
            NSLayoutConstraint.activate([
                lblWeeks[i].widthAnchor.constraint(equalTo: dayView.widthAnchor, multiplier: 1/7),
                lblWeeks[i].heightAnchor.constraint(equalTo: dayView.widthAnchor, multiplier: 1/7),
                lblWeeks[i].topAnchor.constraint(equalTo: dayView.topAnchor),
                lblWeeks[i].leadingAnchor.constraint(equalTo: (i == 0) ? dayView.leadingAnchor : lblWeeks[i-1].trailingAnchor),
            ])
        }
        
        let cnt = 7
        for i in 0..<lblDays.count {
            
            dayView.addSubview(lblDays[i])
            
            let y: Int = Int(  i / cnt )
            let x: Int = Int(  i % cnt )

            // 공통
            NSLayoutConstraint.activate([
                lblDays[i].widthAnchor.constraint(equalTo: dayView.widthAnchor, multiplier: 1/7),
                lblDays[i].heightAnchor.constraint(equalTo: dayView.widthAnchor, multiplier: 1/7),
                lblDays[i].topAnchor.constraint(equalTo: (y == 0) ? lblWeeks[0].bottomAnchor : lblDays[i-cnt].bottomAnchor),
                lblDays[i].leadingAnchor.constraint(equalTo: (x == 0) ? dayView.leadingAnchor : lblDays[i-1].trailingAnchor),
            ])
            
            // 마지막 아이템
            if i == lblDays.count - 1 {
                nsconst42 = dayView.bottomAnchor.constraint(equalTo: lblDays[i].bottomAnchor)
                nsconst35 = dayView.bottomAnchor.constraint(equalTo: lblDays[i-cnt].bottomAnchor)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calUtil.stanYearMonth.bind { [weak self] str in
            guard let self = self else { return }
            
            self.lblDate.text = str
        }
        
        calUtil.datas.bind { [weak self] arrs in
            guard let self = self else { return }
            
            if arrs.count == self.maxCnt {
                self.nsconst35?.isActive = false
                self.nsconst42?.isActive = true
            }else{
                self.nsconst42?.isActive = false
                self.nsconst35?.isActive = true
            }
            
            for i in 0..<arrs.count {
                self.lblDays[i].text = arrs[i].day
                self.lblDays[i].textColor = arrs[i].isinMonth ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        }
        
        calUtil.reload()
        
    }
}

