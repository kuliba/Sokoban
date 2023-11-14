//
//  ContactsAgent+ContactsListTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 14.11.2023.
//

@testable import ForaBank
import XCTest
import Contacts

final class ContactsAgent_ContactsListTests: XCTestCase {
    
    // MARK: - test fetchContacts
    
    func test_fetchContacts_phoneEquals10Digits_shouldAdd7() throws {
        
        let contactsAgent = ContactsAgent(phoneNumberFormatter: PhoneNumberKitFormater())
        let contact = CNMutableContact()
        let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue :"9630000000" ))
        contact.phoneNumbers = [phone]
        let contacts: [CNContact] = [
            contact
        ]

        let result = contactsAgent.fetchContacts(contacts)
        
        let adressContact: AddressBookContact.EquatableAddressBookContact = .init(
            phone: "+7 963 000-00-00",
            firstName: "",
            middleName: "",
            lastName: "",
            avatar: nil)

        XCTAssertNoDiff(
            result.map {
                AddressBookContact.EquatableAddressBookContact
                    .init(
                        phone: $0.phone,
                        firstName: $0.firstName,
                        middleName: $0.middleName,
                        lastName: $0.lastName,
                        avatar: $0.avatar
                    )
            }, 
            [adressContact]
        )
    }
    
    func test_fetchContacts_phoneLess10Digits_shouldNoAdd7() throws {
        
        let contactsAgent = ContactsAgent(phoneNumberFormatter: PhoneNumberKitFormater())
        let contact = CNMutableContact()
        let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue :"963000000"))
        contact.phoneNumbers = [phone]
        let contacts: [CNContact] = [
            contact
        ]

        let result = contactsAgent.fetchContacts(contacts)
        
        let adressContact: AddressBookContact.EquatableAddressBookContact = .init(
            phone: "+963 000 000",
            firstName: "",
            middleName: "",
            lastName: "",
            avatar: nil)

        XCTAssertNoDiff(
            result.map {
                AddressBookContact.EquatableAddressBookContact
                    .init(
                        phone: $0.phone,
                        firstName: $0.firstName,
                        middleName: $0.middleName,
                        lastName: $0.lastName,
                        avatar: $0.avatar
                    )
            },
            [adressContact]
        )
    }
    
    func test_fetchContacts_phoneMore10Digits_shouldNoAdd7() throws {
        
        let contactsAgent = ContactsAgent(phoneNumberFormatter: PhoneNumberKitFormater())
        let contact = CNMutableContact()
        let phone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue :"96300000000"))
        contact.phoneNumbers = [phone]
        let contacts: [CNContact] = [
            contact
        ]

        let result = contactsAgent.fetchContacts(contacts)
        
        let adressContact: AddressBookContact.EquatableAddressBookContact = .init(
            phone: "+963 000 000 00",
            firstName: "",
            middleName: "",
            lastName: "",
            avatar: nil)

        XCTAssertNoDiff(
            result.map {
                AddressBookContact.EquatableAddressBookContact
                    .init(
                        phone: $0.phone,
                        firstName: $0.firstName,
                        middleName: $0.middleName,
                        lastName: $0.lastName,
                        avatar: $0.avatar
                    )
            },
            [adressContact]
        )
    }
}

private extension AddressBookContact {
    
    struct EquatableAddressBookContact: Equatable {
        
        var id: String { phone }
        let phone: String
        let firstName: String?
        let middleName: String?
        let lastName: String?
        let avatar: ImageData?
    }

    var equatable: EquatableAddressBookContact {
        .init(
            phone: self.phone,
            firstName: self.firstName,
            middleName: self.middleName,
            lastName: self.lastName,
            avatar: self.avatar)
    }
}
