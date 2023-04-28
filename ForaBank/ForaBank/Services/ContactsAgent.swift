//
//  ContactsAgent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 23.05.2022.
//

import Contacts
import Combine

class ContactsAgent: ContactsAgentProtocol {
    
    var phoneNumberFormatter: PhoneNumberFormaterProtocol
    let status: CurrentValueSubject<ContactsAgentStatus, Never>
    private let store: CNContactStore
    
    init(phoneNumberFormatter: PhoneNumberFormaterProtocol) {
        
        self.store = CNContactStore()
        self.phoneNumberFormatter = phoneNumberFormatter
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
    
    func fetchContactsList() throws -> [AddressBookContact] {
        
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
        request.sortOrder = .givenName
        
        try contactStore.enumerateContacts(with: request) { (contact, stop) in
            
            contacts.append(contact)
        }
        
        return contacts.flatMap { contact in
            
            contact
                .phoneNumbers
                .map(\.value)
                .compactMap { $0.value(forKey: "digits") as? String }
                .map(phoneNumberFormatter.format)
                .map {
                    .init(
                        phone: $0,
                        firstName: contact.givenName,
                        middleName: contact.middleName,
                        lastName: contact.familyName,
                        avatar: avatar(for: contact)
                    )
                }
        }
    }
    
    private func avatar(for contact: CNContact) -> ImageData? {
        
        guard let thumbnailImageData = contact.thumbnailImageData
        else { return nil }

        return ImageData(data: thumbnailImageData)
      }
}
