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
    /// Для отправки перевода используем эту модель
    var requestModel = (to: "", from: "")
    let moneyInputController = TextFieldStartInputController()
    /// Меняем символ валюты в  textField
    var currencySymbol = "" {
        didSet {
            guard moneyFormatter != nil else { return }
            if isEnable, let amount = amountTextField.text {
                
                setupMoneyController(amount: amount, currency: self.currencySymbol)
            }
        }
    }
    var maxSum: Double?
    
    var isEnable = true
    /// Инициализируем модели карт
    var models = (to: "", from: "") {
        didSet {
            currencySymbol = models.to.getSymbol() ?? ""
            if (models.to != models.from) && (models.to != "" && models.from != "") {
                DispatchQueue.main.async {
                    self.exchangeRate(self.models.to, self.models.from)
                }
            } else {
                
                if isEnable {
                    self.buttomLabel.text = "Возможна комиссия"
                    
                } else {
                    self.buttomLabel.text = "Условия снятия"
                }
            }
        }
    }
    
    // MARK: - Formatters
    var moneyFormatter = SumTextInputFormatter(textPattern: "# ###,##")
    
    
    //MARK: - Property
    let kContentXibName = "BottomInputViewWithRate"
    var switchIsChanged: ((UISwitch) -> Void)?
    @IBOutlet weak var infoButton: UIButton!
    
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
        
        self.currencySwitchButton.setBackgroundColor(color: .white, forState: [.selected])
        
        self.currencySwitchButton.layer.cornerRadius = 12
        self.currencySwitchButton.layer.masksToBounds = true
        if let amount = amountTextField.text {
            
            setupMoneyController(amount: amount, currency: self.currencySymbol)
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: amountTextField, queue: .main) { _ in
            guard let text = self.amountTextField.text else { return }
            guard let unformatText = self.moneyFormatter.unformat(text) else { return }
            self.tempTextFieldValue = unformatText
            self.doneButtonIsEnabled(unformatText.isEmpty)
            
            self.currencySymbol = self.models.to.getSymbol() ?? ""
            UIView.animate(withDuration: 0.2) {
                self.topLabel.alpha = text.isEmpty ? 0 : 1
                self.buttomLabel.alpha = text.isEmpty ? 0 : 1
            }
            
            if self.currencySymbol != "" {
                self.exchangeRate(self.models.to, self.models.from)
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let amount = amountTextField.text else { return }
        let unformatText = moneyFormatter.unformat(amount)
        let text = unformatText?.replacingOccurrences(of: ",", with: ".")
        
        if !(text?.isEmpty ?? true) {
            
            didDoneButtonTapped?(text ?? "")
            
        }
    }
    
    /// Добавляем в textField символ валюты
    func setupMoneyController(amount: String, currency: String) {
        
        guard let unformatText = self.moneyFormatter.unformat(amount) else { return }
        
        self.moneyFormatter = SumTextInputFormatter(textPattern: "# ###,## \(currency)")
        self.moneyInputController.formatter = self.moneyFormatter
        self.amountTextField.delegate = self.moneyInputController
        
        let newText = self.moneyFormatter.format(unformatText)
        self.amountTextField.text = newText
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

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
