

import Foundation

protocol IPresentationModel {
}

extension String: IPresentationModel {
    
}

protocol ICellProvider: class {
//    var segueId: String? { get }
    var isLoading: Bool { get }
//    var currentValue: PaymentOption { get }
    func getData(completion: @escaping (_ data: [IPresentationModel]) -> ())
}

protocol ITextInputCellProvider: ICellProvider, UITextFieldDelegate {
    var iconName: String { get }
    var placeholder: String { get }
    var charactersMaxCount: Int { get }
    var keyboardType: UIKeyboardType { get }
    var isActiveRigthTF: Bool { get } // активируем левую кнопку в TextField
    var recipientType: RecipientType { get } // тип рекзивиза получателя
    func formatted(stringToFormat string: String) -> String
}


//определяем тип рекзивиза получателя
enum RecipientType{
    case byPhoneNumber // по номеру телефона
    case byAccountNumber // по номеру счета
    case byCartNumber // по номеру карты
    case byNone // неизвестно 
}
