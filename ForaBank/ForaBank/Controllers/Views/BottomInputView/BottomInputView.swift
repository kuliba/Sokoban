//
//  BottomInputView.swift
//  ForaBank
//
//  Created by Mikhail on 25.06.2021.
//

import UIKit
import AnyFormatKit

class BottomInputView: UIView {
    
    let moneyInputController = TextFieldStartInputController()
    var currency = "₽" {
        didSet {
//            amountTextField.text = ""
            setupMoneyController()
//            amountTextField.text = "111"
        }
    }
    // MARK: - Formatters
    var moneyFormatter: SumTextInputFormatter?
    
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
    
    
    var didDoneButtonTapped: ((_ amount: String) -> Void)?
    
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
        self.heightAnchor.constraint(equalToConstant: 88).isActive = true
        setupTextFIeld()
//        setupMoneyController()
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: amountTextField, queue: .main) { _ in
            guard let text = self.amountTextField.text else { return }
            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            self.doneButtonIsEnabled(unformatText.isEmpty)
            UIView.animate(withDuration: 0.2) {
                self.topLabel.alpha = unformatText.isEmpty ? 0 : 1
                self.buttomLabel.alpha = unformatText.isEmpty ? 0 : 1
            }
        }
        
    }
    
    
    
    @IBAction func currencyButtonTapped(_ sender: Any) {
        print(#function)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        print(#function)
        guard let amaunt = amountTextField.text else { return }
        let unformatText = moneyFormatter?.unformat(amaunt)
        let text = unformatText?.replacingOccurrences(of: ",", with: ".")
        if !(text?.isEmpty ?? true) {
            didDoneButtonTapped?(text ?? "")
        }
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
    
    func doneButtonIsEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.doneButton.backgroundColor = isEnabled ? #colorLiteral(red: 0.2980068028, green: 0.2980631888, blue: 0.3279978037, alpha: 1) : #colorLiteral(red: 1, green: 0.2117647059, blue: 0.2117647059, alpha: 1)
                self.doneButton.isEnabled = isEnabled ? false : true
            }
        }
    }
    
    private func setupMoneyController() {
        var amount = ""
        if let text = amountTextField.text {
            let unformatText = moneyFormatter?.unformat(text)
            amount = unformatText ?? ""
        }
        
        moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## \(self.currency)")
        moneyInputController.formatter = moneyFormatter
        amountTextField.delegate = moneyInputController
        
        let newText = moneyFormatter?.format(amount)
        amountTextField.text = newText
    }
 
}

//extension BottomInputView: TextFieldStartInputController {
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        guard let text = textField.text else { return }
//        self.doneButtonIsEnabled(text.isEmpty)
//        UIView.animate(withDuration: 0.2) {
//            self.topLabel.alpha = text.isEmpty ? 0 : 1
//            self.buttomLabel.alpha = text.isEmpty ? 0 : 1
//        }
//
//    }
//
//
//}

