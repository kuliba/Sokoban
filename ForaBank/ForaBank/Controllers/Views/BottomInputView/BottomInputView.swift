//
//  BottomInputView.swift
//  ForaBank
//
//  Created by Mikhail on 25.06.2021.
//

import UIKit

class BottomInputView: UIView {
    
    //MARK: - Property
    let kContentXibName = "BottomInputView"
    var switchIsChanged: ((UISwitch) -> Void)?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topLabel: UILabel! {
        didSet {
            buttomLabel.alpha = 0
        }
    }
    @IBOutlet weak var buttomLabel: UILabel! {
        didSet {
            buttomLabel.alpha = 0
        }
    }
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var currencySwitchButton: UIButton! {
        didSet {
            currencySwitchButton.isHidden = true
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.isEnabled = false
        }
    }
    
    var didDoneButtonTapped: (() -> Void)?
    
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
        amountTextField.delegate = self
        self.heightAnchor.constraint(equalToConstant: 88).isActive = true
        setupTextFIeld()
    }
    
    
    @IBAction func currencyButtonTapped(_ sender: Any) {
        print(#function)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        print(#function)
        didDoneButtonTapped?()
    }
    
    private func setupTextFIeld() {
        amountTextField.textColor = .white
        amountTextField.font = .systemFont(ofSize: 24)
        amountTextField.attributedPlaceholder = NSAttributedString(
            string: "Сумма перевода",
            attributes: [.foregroundColor: #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1),
                         .font: UIFont.systemFont(ofSize: 14)
        ])
    }
    
}

extension BottomInputView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        UIView.animate(withDuration: 0.2) {
            self.doneButton.backgroundColor = text.isEmpty ? #colorLiteral(red: 0.8274509804, green: 0.8274509804, blue: 0.8274509804, alpha: 1) : #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
            self.doneButton.isEnabled = text.isEmpty ? false : true
            self.topLabel.alpha = text.isEmpty ? 0 : 1
            self.buttomLabel.alpha = text.isEmpty ? 0 : 1
        }
        
    }
}
