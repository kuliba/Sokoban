//
//  TextFieldPagerViewCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import FSPagerView

class TextFieldPagerViewCell: FSPagerViewCell, IConfigurableCell, ContactsPickerDelegate {

    @IBOutlet weak var rightButtonInTF: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nameContact: UILabel!
    
    // действие для rightButtonInTF
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        if recipientType == .byPhoneNumber{ // открываем контакты если реквизит номер телефона
            contactsListPresent()
        }else if recipientType == .byCartNumber{ // открываем скан если реквизит карта
            showScanCardController(delegate: self)
        }
    }

    weak var delegate: ConfigurableCellDelegate?

    var charactersMaxCount: Int?
    var formattingFunc: ((String) -> (String))?
    var recipientType: RecipientType = .byNone

    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError) {
        print("Failed with error \(error.description)")
    }

    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact) {
        print("Contact \(contact.displayName) has been selected")
    }

    func contactPickerDidCancel(_ picker: ContactsPicker) {
        picker.dismiss(animated: true, completion: nil)
        print("User canceled the selection")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let placeholder = textField.placeholder
        textField.attributedPlaceholder = NSAttributedString(string: placeholder ?? ""
                                                             , attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }

    public func configure(provider: ICellProvider, delegate: ConfigurableCellDelegate) {
        self.delegate = delegate
        
        guard let textInputCellProvider = provider as? ITextInputCellProvider else {
            return
        }
        self.rightButtonInTF.isHidden = !textInputCellProvider.isActiveRigthTF
        self.recipientType = textInputCellProvider.recipientType //записываем тип реквизита получателя
        
        if self.recipientType == .byPhoneNumber{ // если по номеру телефона
            self.rightButtonInTF.setImage(UIImage(named: "user-plus"), for: .normal)
        }else if self.recipientType == .byCartNumber{ // если по номеру карты
            self.rightButtonInTF.setImage(UIImage(named: "card_scan"), for: .normal)
        }
        
        
        textField.text = ""
        formattingFunc = textInputCellProvider.formatted
        charactersMaxCount = textInputCellProvider.charactersMaxCount

        
        //leftButton.setImage(UIImage(named: textInputCellProvider.iconName), for: .normal)
        leftButton.setBackgroundImage(UIImage(named: textInputCellProvider.iconName), for: .normal)

        textField.delegate = self
        textField.placeholder = textInputCellProvider.placeholder
        textField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        textField.sendActions(for: .editingChanged)

        let placeholder = textField.placeholder
        textField.attributedPlaceholder = NSAttributedString(string: placeholder ?? ""
                                                             , attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
}

 
// MARK: UITextFieldDelegate
extension TextFieldPagerViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let nonNilCharactersMaxCount = charactersMaxCount else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= nonNilCharactersMaxCount
    }
    
    //начало записи в поле
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.recipientType == .byPhoneNumber && textField.text == ""{ //если есть кнопка "контакты" считаем, что это поле для номера
            textField.text = "+7" //записываем "+7" при первом нажатии
        }
        
    }
    
    //конец записи в поле
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "+7"{ // очищаем поле если не было записей
            textField.text = ""
        }
    }

    @objc private func reformatAsCardNumber(textField: UITextField) {
        guard let text = textField.text, let nonNilFormattingFunc = formattingFunc else { return }
        let formatedText = nonNilFormattingFunc(text)
        textField.text = formatedText
        delegate?.didInputPaymentValue(value: cleanNumberString(string: text))
    }

    public func contactPicker(_ picker: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        guard !contacts.isEmpty else { return }
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName)", "\(contact.phoneNumbers)")
            var number: String
            nameContact.isHidden = true
            number = "\(contact.phoneNumbers[0])"
            if number[number.startIndex] == "+" {
                number.removeFirst(2)
            } else {
                number.remove(at: number.startIndex)
            }
            print(number)
            let numberFormatted = formattedNumberInPhoneContacts(number: String(number))
            textField.text = "\(numberFormatted)"
            delegate?.didInputPaymentValue(value: cleanNumberString(string: numberFormatted))
        }
    }
}

extension TextFieldPagerViewCell: CardIOPaymentViewControllerDelegate {
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }

    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            textField.text = info.cardNumber
            textField.sendActions(for: .editingChanged)
        }
        paymentViewController.dismiss(animated: true, completion: nil)
    }
}

//MARK: Contacts List Present
extension TextFieldPagerViewCell{
    private func contactsListPresent(){
        let contactPickerScene = ContactsPicker(delegate: self, multiSelection: true, subtitleCellType: SubtitleCellValue.phoneNumber)

        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        topMostVC()?.present(navigationController, animated: true, completion: nil)
    }
}
