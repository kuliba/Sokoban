//
//  ContactsViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import Foundation
import SwiftUI

class ContactsViewModel {
    
    let title = "Выберите контакт"
    let contacts: [Contact]
    let searchViewModel: SearchBarComponent.ViewModel
    let topListViewModel: [TopListViewModel]?
    @Published var selfContact: Contact?
    
    init(_ model: Model, searchViewModel: SearchBarComponent.ViewModel, selfContact: Contact?, topListViewModel: [TopListViewModel]?) {
        
        self.searchViewModel = searchViewModel
        let contacts = Self.reduce(addressBookContact: model.contactsAgent.fetchContactsList())
        self.contacts = contacts
        self.selfContact = selfContact
        self.topListViewModel = topListViewModel
    }
    
    init(contacts: [AddressBookContact], searchViewModel: SearchBarComponent.ViewModel, selfContact: Contact?, topListViewModel: [TopListViewModel]?) {
        
        self.searchViewModel = searchViewModel
        self.contacts = Self.reduce(addressBookContact: contacts)
        self.selfContact = selfContact
        self.topListViewModel = topListViewModel
    }
    
    class Contact: Identifiable, Hashable {
        
        let id = UUID()
        let fullName: String?
        let phone: String
        let image: Image?
        @Published var icon: Image?
        
        internal init(fullName: String?, image: Image?, phone: String) {
            
            self.phone = phone
            self.fullName = fullName
            self.image = image
            self._icon = .init(initialValue: .ic24LogoForaColor)
        }
        
        static func == (lhs: ContactsViewModel.Contact, rhs: ContactsViewModel.Contact) -> Bool {
            
            lhs.fullName == rhs.fullName && lhs.phone == rhs.phone
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(phone)
        }
    }
    
    class TopListViewModel: Identifiable, Hashable {
        
        let id = UUID()
        let image: Image?
        let name: String
        let description: String?
        
        internal init(image: Image?, name: String, description: String?) {
            self.image = image
            self.name = name
            self.description = description
        }
        
        static func == (lhs: ContactsViewModel.TopListViewModel, rhs: ContactsViewModel.TopListViewModel) -> Bool {
            lhs.name == rhs.name && lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(name)
        }
    }
    
    static func reduce(addressBookContact: [AddressBookContact]) -> [Contact] {
        
        var contacts = [Contact]()
        
        for contact in addressBookContact {
        
            contacts.append(.init(fullName: contact.fullName, image: contact.avatar?.image, phone: contact.phone))
            
        }
        
        return contacts
    }
}

extension ContactsViewModel {
    
    static let sample: ContactsViewModel = .init(contacts: [.init(phone: "+7 925 279 86 13", firstName: "Иван", middleName: "Иванович", lastName: "Иванов", avatar: nil), .init(phone: "+7 925 279 86 13", firstName: "Иван", middleName: "Иванович", lastName: "Иванов", avatar: nil)], searchViewModel: .init(placeHolder: .contacts), selfContact: .init(fullName: "Себе", image: nil, phone: "+7 925 279 86 13"), topListViewModel: [.init(image: nil, name: "+7 925 279 86 13", description: nil)])
    
    static let emptyNameSample: ContactsViewModel = .init(contacts: [.init(phone: "+7 925 279 86 13", firstName: nil, middleName: nil, lastName: nil, avatar: nil), .init(phone: "+7 925 279 86 13", firstName: "Иван", middleName: "Иванович", lastName: "Иванов", avatar: nil)], searchViewModel: .init(isEditing: true, placeHolder: .contacts), selfContact: nil, topListViewModel: nil)
}
