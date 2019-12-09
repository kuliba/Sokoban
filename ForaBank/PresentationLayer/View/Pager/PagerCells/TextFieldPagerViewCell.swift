//
//  TextFieldPagerViewCell.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import FSPagerView

class TextFieldPagerViewCell: FSPagerViewCell, IConfigurableCell {

    @IBOutlet weak var buttonContactList: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nameContact: UILabel!

    @IBAction func scanButtonClicked(_ sender: UIButton) {
        showScanCardController(delegate: self)
    }

    @IBAction func contactsList(_ sender: Any) {
        let contactPickerScene = ContactsPicker(delegate: self, multiSelection: true, subtitleCellType: SubtitleCellValue.phoneNumber)

        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        topMostVC()?.present(navigationController, animated: true, completion: nil)
    }


    var newValueCallback: ((_ newValue: IPresentationModel) -> ())?
    var charactersMaxCount: Int?
    var formattingFunc: ((String) -> (String))?


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


    func configure(provider: ICellProvider) {
        guard let textInputCellProvider = provider as? ITextInputCellProvider else {
            return
        }

        scanButton.isHidden = !textInputCellProvider.isScan
        textField.keyboardType = textInputCellProvider.keyboardType
        formattingFunc = textInputCellProvider.formatted
        charactersMaxCount = textInputCellProvider.charactersMaxCount
        newValueCallback = { (newValue) in
            textInputCellProvider.currentValue = newValue
        }

        if textInputCellProvider.currentValue == nil {
            self.textField.reloadInputViews()

            textInputCellProvider.currentValue = textField.text
        }
        buttonContactList.isHidden = true
        if provider is PhoneNumberCellProvider {
            textField.text = "+7"
            buttonContactList.isHidden = false

        }
        textField.delegate = self
        textField.placeholder = textInputCellProvider.placeholder
        textField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)

        leftButton.setImage(UIImage(named: textInputCellProvider.iconName), for: .normal)

        let placeholder = textField.placeholder
        textField.attributedPlaceholder = NSAttributedString(string: placeholder ?? ""
                                                             , attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
}

extension TextFieldPagerViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let nonNilCharactersMaxCount = charactersMaxCount else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= nonNilCharactersMaxCount
    }


    @objc func reformatAsCardNumber(textField: UITextField) {
        guard let text = textField.text, let nonNilFormattingFunc = formattingFunc else { return }
        let formatedText = nonNilFormattingFunc(text)
        textField.text = formatedText
        newValueCallback?(cleanNumberString(string: text))
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

extension TextFieldPagerViewCell: ContactsPickerDelegate {

    public func contactPicker(_ picker: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) {

        defer { picker.dismiss(animated: true, completion: nil) }
        guard !contacts.isEmpty else { return }
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName)", "\(contact.phoneNumbers)")


            if contacts != nil {
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
                newValueCallback?(cleanNumberString(string: numberFormatted))
            }
        }

    }
}
