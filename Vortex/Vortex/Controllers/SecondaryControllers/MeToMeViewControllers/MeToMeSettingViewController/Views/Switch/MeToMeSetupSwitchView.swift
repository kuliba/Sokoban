//
//  MeToMeSetupSwitchView.swift
//  ForaBank
//
//  Created by Mikhail on 16.08.2021.
//

import UIKit

class MeToMeSetupSwitchView: UIView {
    
    //MARK: - Property
    let kContentXibName = "MeToMeSetupSwitchView"
    var switchIsChanged: ((UISwitch) -> Void)?
    
    var heightConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomTextLabel: UILabel!
    @IBOutlet weak var bankByPhoneSwitch: UISwitch!
    @IBOutlet var contentView: UIView!
    
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(viewModel: ForaInputModel(title: ""))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(viewModel: ForaInputModel(title: ""))
    }
    
    required init(frame: CGRect = .zero, viewModel: ForaInputModel) {
        super.init(frame: frame)
        commonInit(viewModel: viewModel)
    }

    
    func commonInit(viewModel: ForaInputModel) {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = self.heightAnchor.constraint(equalToConstant: 104)
        heightConstraint.identifier = "MeToMeSetupSwitchView height constraint"
        heightConstraint.isActive = true

//        configViewWithValue(false)
    }
    
    
    @IBAction func bankByPhoneSwitchTapped(_ sender: UISwitch) {
        configViewWithValue(sender.isOn)
        switchIsChanged?(sender)
    }
    
    func configViewWithValue(_ status: Bool) {
        
        self.bankByPhoneSwitch.isOn = status
        self.heightConstraint.constant = status ? 88 : 104
        self.bottomTextLabel.text = status
            ? "В данном разделе можно произвести настройки для входящих и исходящих переводов СБП"
            : "Подключая возможность осуществлять переводы денежных средств в рамках СБП, соглашаюсь с условиями осуществления переводов СБП."
    }
    
}
