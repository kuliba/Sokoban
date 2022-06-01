//
//  ContactsAgent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 23.05.2022.
//

import Contacts
import Combine

class ContactsAgent: ContactsAgentProtocol {
    
    let status: CurrentValueSubject<ContactsAgentStatus, Never>
    private let store: CNContactStore
    
    init() {
        self.store = CNContactStore()
        self.status = .init(.init(with: CNContactStore.authorizationStatus(for: .contacts)))
    }
    
    func requestPermission() {
        store.requestAccess(for: .contacts) { [unowned self] success, error in

            if success {
                self.status.value = .init(with: CNContactStore.authorizationStatus(for: .contacts))
                    
            } else {
                self.status.value = .failed(error)
            }
        }
    }
    
    func fetchContact(by phoneNumber: String) -> AddressBookContact? {
        
        let clearNumber = CNPhoneNumber(stringValue: "+" + phoneNumber
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
        )
        let predicate = CNContact.predicateForContacts(matching: clearNumber)
          
        let keys = [CNContactGivenNameKey,
                    CNContactMiddleNameKey,
                    CNContactFamilyNameKey,
                    CNContactImageDataAvailableKey,
                    CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]
          
          if let contacts = try? store.unifiedContacts(matching: predicate, keysToFetch: keys),
             let contact = contacts.first {
            
              var imageData: ImageData?
              if let data = contact.thumbnailImageData,
                 contact.imageDataAvailable {
                  imageData = ImageData(data: data)
              }
              
              return AddressBookContact(phone: phoneNumber,
                                       firstName: contact.givenName,
                                       middleName: contact.middleName,
                                       lastName: contact.familyName,
                                       avatar: imageData)
          }
          
        return nil
        
    }
    
}
