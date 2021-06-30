//
//  PhoneContactModel.swift
//  ForaBank
//
//  Created by Дмитрий on 25.06.2021.
//

import Foundation
import ContactsUI

enum ContactsFilter {
       case none
       case mail
       case message
    case name
   }

class PhoneContact: NSObject {

    var name: String?
    var avatarData: Data?
    var phoneNumber: [String] = [String]()
    var email: [String] = [String]()
    var isSelected: Bool = false
    var isInvited = false
    var bankImage: Bool?

    func checkOwner(number: String?) -> Bool?{
//        showActivity()
        let body = [
            "phoneNumber": number
        ] as [String: AnyObject]
        
        var checkOwner: Bool?
        
        NetworkManager<GetOwnerPhoneNumberPhoneDecodableModel>.addRequest(.getOwnerPhoneNumber, [:], body) { model, error in
            if error != nil {
                
                checkOwner = false
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: Card list: ", model)
         

            if model.statusCode == 0 {
                
//                self.selectedCardNumber = cardNumber
                DispatchQueue.main.sync {
                    checkOwner = true
                }
            } else {
                
                checkOwner = false
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        return checkOwner
    }
    
    
    init(contact: CNContact) {
        super.init()
       
        name        = contact.givenName + " " + contact.familyName
        avatarData  = contact.thumbnailImageData
        for phone in contact.phoneNumbers {
            phoneNumber.append(phone.value.stringValue)
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
        
    }

    override init() {
        super.init()
    }
    
}
