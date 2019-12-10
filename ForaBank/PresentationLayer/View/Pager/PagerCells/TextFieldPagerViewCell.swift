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

    @IBOutlet weak var buttonContactList: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nameContact: UILabel!

    @IBAction func contactsList(_ sender: Any) {
        let contactPickerScene = ContactsPicker(delegate: self, multiSelection: true, subtitleCellType: SubtitleCellValue.phoneNumber)

        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        topMostVC()?.present(navigationController, animated: true, completion: nil)
    }

    weak var delegate: ConfigurableCellDelegate?

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

    public func configure(provider: ICellProvider, delegate: ConfigurableCellDelegate) {
        self.delegate = delegate

        guard let textInputCellProvider = provider as? ITextInputCellProvider else {
            return
        }
        
        textField.text = ""
        formattingFunc = textInputCellProvider.formatted
        charactersMaxCount = textInputCellProvider.charactersMaxCount

        buttonContactList.isHidden = true
        if provider is PhoneNumberCellProvider {
            textField.text = "+7"
            buttonContactList.isHidden = false
        }

        leftButton.setImage(UIImage(named: textInputCellProvider.iconName), for: .normal)

        textField.delegate = self
        textField.placeholder = textInputCellProvider.placeholder
        textField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
        textField.sendActions(for: .editingChanged)

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
