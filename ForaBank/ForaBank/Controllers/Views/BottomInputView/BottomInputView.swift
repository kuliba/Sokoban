//
//  BottomInputView.swift
//  ForaBank
//
//  Created by Mikhail on 25.06.2021.
//

import UIKit
import AnyFormatKit

class BottomInputView: UIView {
    
    var currencyFrom: GetExchangeCurrencyDataClass?
    var currencyTo: GetExchangeCurrencyDataClass?
    var tempTextFieldValue = ""
    
    let moneyInputController = TextFieldStartInputController()
    var currencySymbol = "" {
        didSet {
            setupMoneyController()
        }
    }
    
    var currencyCode = "RUB"
    
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
//            print(text)
//            if text.count > 0 {
////                self.currency = "₽"
//                self.setupMoneyController()
//            }

            guard let unformatText = self.moneyFormatter?.unformat(text) else { return }
            self.tempTextFieldValue = unformatText
            self.doneButtonIsEnabled(unformatText.isEmpty)
            UIView.animate(withDuration: 0.2) {
                self.topLabel.alpha = unformatText.isEmpty ? 0 : 1
                self.buttomLabel.alpha = unformatText.isEmpty ? 0 : 1
            }
            self.exchangeRate(unformatText)
        }
}
    
    final func exchangeRate(_ unformatText: String) {
        if (self.currencyFrom != nil || self.currencyTo != nil) && self.currencySwitchButton.isHidden != true {
            currencyToSimbol = currencyTo?.currencyCodeAlpha?.getSymbol() ?? ""
            currencyFromSimbol = currencyFrom?.currencyCodeAlpha?.getSymbol() ?? ""
            tempArray = [currencyTo, currencyFrom]
            
            
            let currencyToSimbol = self.currencyTo?.currencyCodeAlpha?.getSymbol() ?? ""
            let currencyFromSimbol = self.currencyFrom?.currencyCodeAlpha?.getSymbol() ?? ""
            let currencyToValue = String(self.currencyTo?.rateBuy ?? 0)
            let currencyFromValue = String(self.currencyFrom?.rateSell ?? 0)
            
            /// Вычисляем итоговую суммы перевода
            /// 1.   Если одна из валют рубли
            let (from, to) = (self.currencyFrom?.currencyName, self.currencyTo?.currencyName)
            let ru = (from == nil || to == nil)
            
            switch ru {
            
            case true:
                /// Если одна из валют выбранной карты в рублях, то ищем которая
                if from != to {
                    switch (from, to) {
                    case (nil, _):
                        let tempValue = unformatText.toDouble() ?? 0
                        let resultSum = (tempValue / (self.currencyTo?.rateBuy ?? 0)).rounded(toPlaces: 2)
                        
                        let tempBottomLable = String(resultSum) + currencyToSimbol + "  |  " + "1" + currencyToSimbol + " - " + currencyToValue +  self.currencySymbol
                        let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                        self.buttomLabel.text = tempLable
                        self.currencyCode = "RUB"
                        
                    case (_, nil):
        
                        let tempValue = unformatText.toDouble() ?? 0
                        let resultSum = ( tempValue * (self.currencyFrom?.rateSell ?? 0) ).rounded(toPlaces: 2)
                        
                        let tempBottomLable = String(resultSum) + "₽" + "  |  " + "1" + currencyFromSimbol + " - " + currencyFromValue + "₽"
                        let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                        self.buttomLabel.text = tempLable
                        self.currencyCode = self.currencyFrom?.currencyCodeAlpha ?? ""
                    case (_, _):
                        break
                    }
                }
            case false:
            /// Если обе валюты в выбранных картах в рублях не в рублях
                let tempValue = (unformatText as NSString).doubleValue
                let resultSum = ( tempValue * ((self.currencyFrom?.rateBuy ?? 0) / (self.currencyTo?.rateSell ?? 0))).rounded(toPlaces: 2)
                let a = String(((self.currencyFrom?.rateBuy ?? 0) / (self.currencyTo?.rateSell ?? 0)).rounded(toPlaces: 2))
                
                
                let tempBottomLable = String(resultSum) + currencyToSimbol + "  |  " + "1" + currencyFromSimbol + " - " + a +  currencyToSimbol
                let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                self.buttomLabel.text = tempLable
                self.currencyCode = self.currencyFrom?.currencyCodeAlpha ?? ""
                print(self.currencyFrom?.currencyCodeAlpha)
            }
        }
    }
    var currencyToSimbol = ""
    var currencyFromSimbol = ""
    var tempArray = [GetExchangeCurrencyDataClass?]()
    
    @IBAction func currencyButtonTapped(_ sender: UIButton) {
        
        guard tempArray.count != 0 else { return }
        
        let (from, to) = (self.currencyFrom?.currencyName, self.currencyTo?.currencyName)
        let ru = (from == nil || to == nil)
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            switch ru {
            case true:
                if from != to {
                    switch (from, to) {
                    case (nil, _):
                        let reversArray = Array(tempArray.reversed())
                        currencySymbol = "₽"
                        self.currencySwitchButton.setTitle("₽" + " ⇆ " + (reversArray[1]?.currencyCodeAlpha?.getSymbol() ?? ""), for: .normal)
                        let tempValue = self.tempTextFieldValue.toDouble() ?? 0
                        let resultSum = (tempValue / (reversArray[1]?.rateBuy ?? 0)).rounded(toPlaces: 2)
                        
                        let tempBottomLable = String(resultSum) + self.currencyToSimbol + "  |  " + "1" + "₽" + " - " + String(reversArray[1]?.rateBuy ?? 0) +  self.currencySymbol
                        let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                        self.buttomLabel.text = tempLable
                        self.currencyCode = reversArray[1]?.currencyCodeAlpha ?? ""
                        
                    case (_, nil):
                        let reversArray = Array(tempArray.reversed())
                        currencySymbol = reversArray[0]?.currencyCodeAlpha?.getSymbol() ?? ""
                        self.currencySwitchButton.setTitle((reversArray[0]?.currencyCodeAlpha?.getSymbol() ?? "") + " ⇆ " + "₽", for: .normal)
                        let tempValue = self.tempTextFieldValue.toDouble() ?? 0
                        let resultSum = ( tempValue * (reversArray[0]?.rateBuy ?? 0) ).rounded(toPlaces: 2)
                        
                        let tempBottomLable = String(resultSum) + "₽" + "  |  " + "1" + self.currencyFromSimbol + " - " + String(reversArray[0]?.rateBuy ?? 0) + "₽"
                        let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                        self.buttomLabel.text = tempLable
                        self.currencyCode = reversArray[0]?.currencyCodeAlpha ?? ""
                    case (_, _):
                        break
                    }
                }
            case false:
                let reversArray = Array(tempArray.reversed())
                self.currencySwitchButton.setTitle((reversArray[1]?.currencyCodeAlpha?.getSymbol() ?? "") + " ⇆ " + (reversArray[0]?.currencyCodeAlpha?.getSymbol() ?? ""), for: .normal)
                currencySymbol = currencyToSimbol
                let tempValue = self.tempTextFieldValue.toDouble() ?? 0
                let resultSum = ( tempValue * ((reversArray[1]?.rateBuy ?? 0) / (reversArray[0]?.rateSell ?? 0))).rounded(toPlaces: 2)
                let a = String(((reversArray[1]?.rateBuy ?? 0) / (reversArray[0]?.rateSell ?? 0)).rounded(toPlaces: 2))
                let tempBottomLable = String(resultSum) + currencyFromSimbol + "  |  " + "1" + currencyToSimbol + " - " + a +  currencyFromSimbol
                let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                self.buttomLabel.text = tempLable
                self.currencyCode = reversArray[1]?.currencyCodeAlpha ?? ""
            }
            } else {
                switch ru {
                case true:
                    if from != to {
                        switch (from, to) {
                        case (nil, _):
                            self.currencySymbol = self.tempArray[0]?.currencyCodeAlpha?.getSymbol() ?? ""
                            self.currencySwitchButton.setTitle((self.tempArray[0]?.currencyCodeAlpha?.getSymbol() ?? "") + " ⇆ " + "₽", for: .normal)
                            let tempValue = self.tempTextFieldValue.toDouble() ?? 0
                            let resultSum = (tempValue * (self.tempArray[0]?.rateSell ?? 0)).rounded(toPlaces: 2)
                            
                            let tempBottomLable = String(resultSum) + "₽" + "  |  " + "1" + "₽" + " - " + String(self.tempArray[0]?.rateSell ?? 0) +  self.currencySymbol
                            let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                            self.buttomLabel.text = tempLable
                            self.currencyCode = self.tempArray[0]?.currencyCodeAlpha ?? ""
                            
                        case (_, nil):
                            self.currencySymbol = "₽"
                            self.currencySwitchButton.setTitle("₽" + " ⇆ " + (self.tempArray[1]?.currencyCodeAlpha?.getSymbol() ?? ""), for: .normal)
                            let tempValue = self.tempTextFieldValue.toDouble() ?? 0
                            let resultSum = ( tempValue / (self.tempArray[1]?.rateSell ?? 0) ).rounded(toPlaces: 2)
                            let curSymbol = self.tempArray[1]?.currencyCodeAlpha?.getSymbol() ?? ""
                            let tempBottomLable = String(resultSum) + curSymbol + "  |  " + "1" + self.currencyFromSimbol + " - " + String(self.tempArray[1]?.rateSell ?? 0) + "₽"
                            let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                            self.buttomLabel.text = tempLable
                            self.currencyCode = self.tempArray[1]?.currencyCodeAlpha ?? ""
                        case (_, _):
                            break
                        }
                    }
                case false:
                
                self.currencySwitchButton.setTitle((self.tempArray[1]?.currencyCodeAlpha?.getSymbol() ?? "") + " ⇆ " + (self.tempArray[0]?.currencyCodeAlpha?.getSymbol() ?? ""), for: .normal)
                
                self.currencySymbol = self.currencyFromSimbol
                let tempValue = self.tempTextFieldValue.toDouble() ?? 0
                let resultSum = ( tempValue * ((self.tempArray[1]?.rateBuy ?? 0) / (self.tempArray[0]?.rateSell ?? 0))).rounded(toPlaces: 2)
                let a = String(((self.tempArray[1]?.rateBuy ?? 0) / (self.tempArray[0]?.rateSell ?? 0)).rounded(toPlaces: 2))
                
                
                let tempBottomLable = String(resultSum) + self.currencyToSimbol + "  |  " + "1" + self.currencyFromSimbol + " - " + a +  self.currencyToSimbol
                let tempLable = tempBottomLable.replacingOccurrences(of: ".", with: ",")
                self.buttomLabel.text = tempLable
                self.currencyCode = self.tempArray[1]?.currencyCodeAlpha ?? ""
            }
            }
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

