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
    
    private let currencyFormatter = CurrencyFormatter(maximumFractionDigits: 2)
    
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
        amountTextField.delegate = self
        self.heightAnchor.constraint(equalToConstant: 88).isActive = true
        setupTextFIeld()
    }
    
    
    @IBAction func currencyButtonTapped(_ sender: Any) {
        print(#function)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        print(#function)
        guard let amaunt = amountTextField.text else { return }
        if !amaunt.isEmpty {
            didDoneButtonTapped?(amaunt)
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
    
    
}

extension BottomInputView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.doneButtonIsEnabled(text.isEmpty)
        UIView.animate(withDuration: 0.2) {
            self.topLabel.alpha = text.isEmpty ? 0 : 1
            self.buttomLabel.alpha = text.isEmpty ? 0 : 1
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        guard !newText.isEmpty, textField.keyboardType == .decimalPad else { return true }
        
        let separator = self.currencyFormatter.decimalSeparator!
        let components = newText.components(separatedBy: separator)
        
        
        // Stop exceeding maximumFractionDigits
        if components.count > 1 && components[1].count > self.currencyFormatter.maximumFractionDigits {
            return false
        }
        
        guard let cleaned = components.first?.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression) else { return true }
        
        var doubleValue: Double?
        if (components.count > 1) {
            doubleValue = Double(cleaned + "." + components[1])
        }
        
        if let value = doubleValue ?? Double(cleaned) {
            var formatted = self.currencyFormatter.beautify(value)
            if (components.count > 1 && (components[1].isEmpty || components[1].range(of: "^0*$", options: .regularExpression) != nil)) {
                formatted += separator + components[1]
            }
            
            
            textField.text =  formatted.currencyInputFormatting()
        }
        
        return false
        
    }
    
    func getSymbol(forCurrencyCode code: String) -> String? {
        let locale = NSLocale(localeIdentifier: code)
        if locale.displayName(forKey: .currencySymbol, value: code) == code {
            let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
            return newlocale.displayName(forKey: .currencySymbol, value: code)
        }
        return locale.displayName(forKey: .currencySymbol, value: code)
    }
    
}



class CurrencyFormatter: NumberFormatter {

    override init() {
        super.init()

        self.currencySymbol = "$"
        self.minimumFractionDigits = 0
        self.numberStyle = .currency
    }

    convenience init(locale: String) {
        self.init()
        self.locale = Locale(identifier: locale)
    }

    convenience init(maximumFractionDigits: Int) {
        self.init()
        self.maximumFractionDigits = maximumFractionDigits
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func beautify(_ price: Double) -> String {
        let formatted = self.string(from: NSNumber(value: price))!

        // Fixes an extra space that is left sometimes at the end of the string
        return formatted.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}

extension String {

    // formatting text for currency textField
    func currencyInputFormatting() -> String {

        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        var amountWithPrefix = self

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")

        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))

        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }

        return formatter.string(from: number)!
    }
}
