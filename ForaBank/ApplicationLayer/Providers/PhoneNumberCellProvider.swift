

import Foundation

class PhoneNumberCellProvider: NSObject, ITextInputCellProvider {
    var recipientType: RecipientType = .byPhoneNumber
//    var segueId: String?
    

    let iconName = "mobileWithBorder"
    let placeholder = "По номеру телефона"
    let charactersMaxCount = 17
    let keyboardType: UIKeyboardType = .phonePad
    let isActiveRigthTF = true
    
    var currentValue: IPresentationModel?
    var isLoading: Bool = false

    func getData(completion: ([IPresentationModel]) -> ()) {
        print("Holla")
    }

    func formatted(stringToFormat string: String) -> String {
        return formattedPhoneNumber(number: string)
    }
}
