//
//  VortexSwitchView.swift
//  Vortex
//
//  Created by Mikhail on 11.06.2021.
//

import UIKit

class VortexSwitchView: UIView {
    
    //MARK: - Property
    let kContentXibName = "VortexSwitchView"
    var switchIsChanged: ((UISwitch) -> Void)?
    
    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var bankByPhoneSwitch: UISwitch!
    @IBOutlet var contentView: UIView!
    
    
    //MARK: - Viewlifecicle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(viewModel: VortexInputModel(title: ""))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(viewModel: VortexInputModel(title: ""))
    }
    
    required init(frame: CGRect = .zero, viewModel: VortexInputModel) {
        super.init(frame: frame)
        commonInit(viewModel: viewModel)
    }

    
    func commonInit(viewModel: VortexInputModel) {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        contentView.fixInView(self)
        self.heightAnchor.constraint(equalToConstant: 64).isActive = true
        bankByPhoneSwitch.set(width: 48, height: 24)
        bankByPhoneSwitch.increaseThumb()
        bankByPhoneSwitch.layer.cornerRadius = 31 / 2
        bankByPhoneSwitch.layer.borderWidth = 1
        bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1)
    }
    
    
    @IBAction func bankByPhoneSwitchTapped(_ sender: UISwitch) {
        switchDidChange(sender)
        switchIsChanged?(sender)
    }
    
    func switchDidChange(_ sender: UISwitch) {
        bankByPhoneSwitch.layer.borderColor = sender.isOn ? #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        bankByPhoneSwitch.thumbTintColor = sender.isOn ? #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.5137254902, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        phoneImage.image = sender.isOn ? UIImage(named: "smartphoneGreen") : UIImage(named: "smartphoneGrey")
        
    }
}
