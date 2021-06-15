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
//        self.viewModel = viewModel
//
//        textField.addTarget(self, action: #selector(setupValue), for: .editingChanged)
//        textField.delegate = self
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    
    @IBAction func bankByPhoneSwitchTapped(_ sender: Any) {
        print(#function)
    }
    
}
