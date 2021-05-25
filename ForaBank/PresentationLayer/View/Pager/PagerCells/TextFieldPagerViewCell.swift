//

import UIKit
import FSPagerView

class TextFieldPagerViewCell: FSPagerViewCell, IConfigurableCell, EPPickerDelegate {

    @IBOutlet weak var rightButtonInTF: UIButton!
//    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var textField: UITextField!
//    @IBOutlet weak var nameContact: UILabel!
    
    var configurateCell: ParameterList? = nil
    var delegateCell: updateDelegate?

    // действие для rightButtonInTF
    @IBAction func scanButtonClicked(_ sender: UIButton) {
        if recipientType == .byPhoneNumber{ // открываем контакты если реквизит номер телефона
            let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:false, subtitleCellType: SubtitleCellValue.phoneNumber)
            contactPickerScene.navigationController?.navigationBar.backgroundColor = .white
            
            
            let navigationController = UINavigationController(rootViewController: contactPickerScene)
            navigationController.navigationBar.backgroundColor = .white
            navigationController.modalPresentationStyle = .fullScreen

            
            navigationController.topViewController?.title = "Контакты"
            navigationController.title = "Контакты"
            navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            navigationController.navigationBar.tintColor = .black
            topMostVC()?.present(navigationController, animated: true, completion: nil)
        }else if recipientType == .byCartNumber{ // открываем скан если реквизит карта
            showScanCardController(delegate: self)
        }
    }
    
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact) {
        if contact.phoneNumbers.count > 0 {
            let strSearch = "\(String(cleanNumber(number: contact.phoneNumbers[0].phoneNumber) ?? "nil"))"
            guard  let cleanNumeber = cleanNumber(number: strSearch) else {return}
            let numberFormatted = formattedNumberInPhoneContacts(number: String(cleanNumeber.dropFirst()))
                  textField.text = "\(numberFormatted)"
                  delegate?.didInputPaymentValue(value: cleanNumberString(string: numberFormatted))
        } else {
            AlertService.shared.show(title: "Ошибка", message: "Нет номера телефона", cancelButtonTitle: "Отмена", okButtonTitle: "Ok", cancelCompletion: nil, okCompletion: nil)
        }
          }
    

    weak var delegate: ConfigurableCellDelegate?

    var charactersMaxCount: Int?
    var formattingFunc: ((String) -> (String))?
    var recipientType: RecipientType = .byNone


    override func awakeFromNib() {
        super.awakeFromNib()
        textField.backgroundColor = .white
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
        leftIcon.image = UIImage(named: textInputCellProvider.iconName)
//        leftIcon.sizeToFit()
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
