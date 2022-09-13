//
//  ContactsAgentMock.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 01.06.2022.
//

import Contacts
import Combine

class ContactsAgentMock: ContactsAgentProtocol {
    
    var status: CurrentValueSubject<ContactsAgentStatus, Never> = .init(.disabled)
    
    func fetchContact(by phoneNumber: String) -> AddressBookContact? {
        return nil
    }
    
    func requestPermission() {}
    
    func fetchContactsList() -> [AddressBookContact] {
        return []
    }
}
