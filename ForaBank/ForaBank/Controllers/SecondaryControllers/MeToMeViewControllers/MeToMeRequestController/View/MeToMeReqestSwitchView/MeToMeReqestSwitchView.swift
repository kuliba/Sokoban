//
//  MeToMeReqestSwitchView.swift
//  ForaBank
//
//  Created by Mikhail on 03.09.2021.
//

import UIKit

class MeToMeReqestSwitchView: UIView {
    
    //MARK: - Property
    let kContentXibName = "MeToMeReqestSwitchView"
    var switchIsChanged: ((UISwitch) -> Void)?
    
    var heightConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomTextLabel: UILabel!
    @IBOutlet weak var bankByPhoneSwitch: UISwitch!
    @IBOutlet var contentView: UIView!
    
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = self.heightAnchor.constraint(equalToConstant: 104)
        heightConstraint.identifier = "MeToMeSetupSwitchView height constraint"
        heightConstraint.isActive = true
        
        bankByPhoneSwitch.set(width: 48, height: 24)
        bankByPhoneSwitch.increaseThumb()
        bankByPhoneSwitch.layer.cornerRadius = 15
        bankByPhoneSwitch.layer.borderWidth = 1
        bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1)

        configViewWithValue(true)
    }
    
    
    @IBAction func bankByPhoneSwitchTapped(_ sender: UISwitch) {
        configViewWithValue(sender.isOn)
        switchIsChanged?(sender)
    }
    
    func configViewWithValue(_ status: Bool) {
        bankByPhoneSwitch.layer.borderColor = status ? #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        bankByPhoneSwitch.thumbTintColor = status ? #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.heightConstraint.constant = 76
        self.bottomTextLabel.text = "Я принимаю условия обслуживания"
    }
    
}
