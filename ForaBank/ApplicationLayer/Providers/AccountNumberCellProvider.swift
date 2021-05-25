

import Foundation

class AccountNumberCellProvider: NSObject, ITextInputCellProvider {
    var recipientType: RecipientType = .byAccountNumber
//    var segueId: String?
    var textField: String = ""
    

    let iconName = "feed_current_account_logo"
    let placeholder = "По номеру счёта"
    let charactersMaxCount = 24
    let keyboardType: UIKeyboardType = .numberPad
    let isActiveRigthTF = false

    var isLoading: Bool = false
    func getData(completion: ([IPresentationModel]) -> ()) {

    }

    func formatted(stringToFormat string: String) -> String {
        return formattedAccountNumberTextField(accountNumberTextField: string)
    }
}
