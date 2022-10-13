//
//  ContactsAgent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 23.05.2022.
//

import Contacts
import Combine
import PhoneNumberKit

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
    
    func clearNumber(for phoneNumber: String) -> String {
         "+" + phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
    }
    
    func fetchContact(by phoneNumber: String) -> AddressBookContact? {
        
        let predicate = CNContact.predicateForContacts(
                            matching: CNPhoneNumber(
                                stringValue: clearNumber(for: phoneNumber)))
          
        let keys = [CNContactGivenNameKey,
                    CNContactMiddleNameKey,
                    CNContactFamilyNameKey,
                    CNContactImageDataAvailableKey,
                    CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]
          
        guard let contacts = try? store.unifiedContacts(matching: predicate, keysToFetch: keys),
              let contact = contacts.first
        else { return nil }

        return AddressBookContact(phone: phoneNumber,
                                  firstName: contact.givenName,
                                  middleName: contact.middleName,
                                  lastName: contact.familyName,
                                  avatar: avatar(for: contact))
    }
    
    func fetchContactsList() -> [AddressBookContact] {
        
        var bookContacts = [AddressBookContact]()
        let phoneNumberKit = PhoneNumberKit()
        var contacts = [CNContact]()
        let keys = [CNContactPhoneNumbersKey,
                    CNContactGivenNameKey,
                    CNContactMiddleNameKey,
                    CNContactFamilyNameKey,
                    CNContactImageDataAvailableKey,
                    CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]

        let request = CNContactFetchRequest(keysToFetch: keys)
        
        let contactStore = CNContactStore()
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                contacts.append(contact)
            }
        } catch {
            
            print("don't try contacts")
        }
        
        for contact in contacts {
            
            if let phoneNumber = (contact.phoneNumbers.first?.value as? CNPhoneNumber)?.value(forKey: "digits") as? String,
               let phone = try? phoneNumberKit.parse(phoneNumber) {
                
                let contactPhone = phoneNumberKit.format(phone, toType: .international)
                
                bookContacts.append(AddressBookContact(phone: contactPhone,
                                                       firstName: contact.givenName,
                                                       middleName: contact.middleName,
                                                       lastName: contact.familyName,
                                                       avatar: avatar(for: contact)))
            }
        }
        
        return bookContacts
    }
    
    private func avatar(for contact: CNContact) -> ImageData? {
        
        guard let thumbnailImageData = contact.thumbnailImageData
        else { return nil }

        return ImageData(data: thumbnailImageData)

      }
}
