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

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var textField: UITextField!

    var newValueCallback: ((_ newValue: IPresentationModel) -> ())?
    var charactersMaxCount: Int?
    var formattingFunc: ((String) -> (String))?

    @IBOutlet weak var nameContact: UILabel!



    @IBAction func contactsList(_ sender: Any) {
        let contactPickerScene = ContactsPicker(delegate: self, multiSelection: true, subtitleCellType: SubtitleCellValue.phoneNumber)

        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        topMostVC()?.present(navigationController, animated: true, completion: nil)
    }
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError) {
        print("Failed with error \(error.description)")
    }

  
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact) {
        print("Contact \(contact.displayName) has been selected")

    }

    func contactPickerDidCancel(_ picker: ContactsPicker) {
        picker.dismiss(animated: true, completion: nil)
        print("User canceled the selection")
    }


    func contactPicker(_ picker: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        guard !contacts.isEmpty else { return }
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName)", "\(contact.phoneNumbers)")


            if contacts != nil {
                let number: String
                nameContact.isHidden = true
                number = "\(contact.phoneNumbers.joined())"
                let numberFormatted = formattedPhoneNumber(number: number)
                textField.text = "\(numberFormatted)"

            }
            }
        }



        override func awakeFromNib() {
            super.awakeFromNib()
        }

        func configure(provider: ICellProvider) {
            guard let textInputCellProvider = provider as? ITextInputCellProvider else {
                return
            }


            formattingFunc = textInputCellProvider.formatted
            charactersMaxCount = textInputCellProvider.charactersMaxCount
            newValueCallback = { (newValue) in
                textInputCellProvider.currentValue = newValue
            }

            if provider is PhoneNumberCellProvider {
                textField.text = "+7"
            }
            textField.delegate = self
            textField.placeholder = textInputCellProvider.placeholder
            textField.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)


            leftButton.setImage(UIImage(named: textInputCellProvider.iconName), for: .normal)
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
