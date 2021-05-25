

import Foundation

class CardNumberCellProvider: NSObject, ITextInputCellProvider {
    
//    var segueId: String?
    
    var recipientType: RecipientType = .byCartNumber
    let iconName = "card-colored"
    let placeholder = "По номеру карты"
    let charactersMaxCount = 19
    let keyboardType: UIKeyboardType = .numberPad
    let isActiveRigthTF = true

    var currentValue: IPresentationModel?
    var isLoading: Bool = false

    func getData(completion: ([IPresentationModel]) -> ()) {

    }

    func formatted(stringToFormat string: String) -> String {
        return formatedCreditCardString(creditCardString: string)
    }
}
