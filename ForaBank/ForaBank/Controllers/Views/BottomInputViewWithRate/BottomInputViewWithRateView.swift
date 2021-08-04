//
//  FileBottomInputViewWithRateView.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import UIKit
import AnyFormatKit

class BottomInputViewWithRateView: UIView {
    
    lazy var bottomLable = BottomLableModel()
    
    var tempTextFieldValue = ""
    
    let moneyInputController = TextFieldStartInputController()
    /// Меняем символ валюты в  textField
    var currencySymbol = "" {
        didSet {
            setupMoneyController()
        }
    }
    /// Инициализируем модели карт
    var models = (to: "", from: "") {
        didSet {
            currencySymbol = models.to.getSymbol() ?? ""
            exchangeRate(models.to, models.from)
        }
    }
    
    // MARK: - Formatters
    var moneyFormatter: SumTextInputFormatter?
    
    //MARK: - Property
    let kContentXibName = "BottomInputViewWithRate"
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
        self.currencySwitchButton.setBackgroundColor(.white, for: .selected)
        self.currencySwitchButton.setBackgroundColor(.white, for: .disabled)
        self.currencySwitchButton.setBackgroundColor(.white, for: .highlighted)
        self.currencySwitchButton.setBackgroundColor(.white, for: .normal)
        self.currencySwitchButton.layer.cornerRadius = 12
        self.currencySwitchButton.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: amountTextField, queue: .main) { _ in
            guard let text = self.amountTextField.text else { return }
            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            self.tempTextFieldValue = unformatText
            self.doneButtonIsEnabled(unformatText.isEmpty)
            
            self.currencySymbol = self.models.to.getSymbol() ?? ""
            UIView.animate(withDuration: 0.2) {
                self.topLabel.alpha = text.isEmpty ? 0 : 1
                self.buttomLabel.alpha = text.isEmpty ? 0 : 1
            }
        
//            if unformatText == "" {
//                self.currencySymbol = ""
//            } else {
//                self.currencySymbol = self.models.to.getSymbol() ?? ""
//                UIView.animate(withDuration: 0.2) {
//                    self.topLabel.alpha = text.isEmpty ? 0 : 1
//                    self.buttomLabel.alpha = text.isEmpty ? 0 : 1
//                }
//            }
            
            self.exchangeRate(self.models.to, self.models.from)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let amaunt = amountTextField.text else { return }
        let unformatText = moneyFormatter?.unformat(amaunt)
        let text = unformatText?.replacingOccurrences(of: ",", with: ".")
        if !(text?.isEmpty ?? true) {
            didDoneButtonTapped?(text ?? "")
        }
    }
    
    /// Добавляем в textField символ валюты
   private func setupMoneyController() {
        DispatchQueue.main.async {
            var amount = ""
            if let text = self.amountTextField.text {
                let unformatText = self.moneyFormatter?.unformat(text)
                amount = unformatText ?? ""
            }
            self.moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## \(self.currencySymbol)")
            self.moneyInputController.formatter = self.moneyFormatter
            self.amountTextField.delegate = self.moneyInputController
            
            let newText = self.moneyFormatter?.format(amount)
            self.amountTextField.text = newText
        }
    }
    
    @IBAction func currencyButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == false {
            reversedRate(models.to, models.from)
        } else {
            reversedRate(models.from, models.to)
        }
    }
}
