//
//  ForaSwitchView.swift
//  ForaBank
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit

class ForaSwitchView: UIView {
    
    //MARK: - Property
    let kContentXibName = "ForaSwitchView"
    var switchIsChanged: ((UISwitch) -> Void)?
    
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
        self.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        bankByPhoneSwitch.layer.cornerRadius = 31 / 2
        bankByPhoneSwitch.layer.borderWidth = 1
        bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1)
        bankByPhoneSwitch.increaseThumb()
        
    }
    
    
    @IBAction func bankByPhoneSwitchTapped(_ sender: UISwitch) {
        switchDidChange(sender)
        switchIsChanged?(sender)
    }
    
    private func switchDidChange(_ sender: UISwitch) {
        bankByPhoneSwitch.layer.borderColor = sender.isOn ? #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        bankByPhoneSwitch.thumbTintColor = sender.isOn ? #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    }
}
