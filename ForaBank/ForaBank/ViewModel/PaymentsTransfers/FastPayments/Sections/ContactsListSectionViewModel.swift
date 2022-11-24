//
//  ContactsListSectionViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import SwiftUI
import Combine

class ContactsListSectionViewModel: ContactsSectionViewModel, ObservableObject {
    
    override var type: ContactsSectionViewModel.Kind { .contacts }
    
    @Published var selfContact: ContactsPersonItemView.ViewModel?
    @Published var visible: [ContactsItemViewModel]
    let filter: CurrentValueSubject<String?, Never>
    
    private let contacts: CurrentValueSubject<[ContactsItemViewModel], Never>
    private let phoneFormatter: PhoneNumberFormaterProtocol

    init(_ model: Model, selfContact: ContactsPersonItemView.ViewModel?, visible: [ContactsItemViewModel], contacts: [ContactsItemViewModel], filter: String?, phoneFormatter: PhoneNumberFormaterProtocol = PhoneNumberKitFormater(), mode: Mode) {
        
        self.selfContact = selfContact
        self.visible = visible
        self.filter = .init(filter)
        self.contacts = .init(contacts)
        self.phoneFormatter = phoneFormatter
        super.init(model: model, mode: mode)
    }
    
    convenience init(_ model: Model, mode: Mode) {
        
        self.init(model, selfContact: nil, visible: [], contacts: [], filter: nil, mode: mode)
        
        Task.detached(priority: .userInitiated) {
            
            do {
                
                let addressBookContacts = try await model.contactsFetchAll()
                self.contacts.value = await Self.reduce(addressBookContacts: addressBookContacts, phoneFormatter: self.phoneFormatter, action: {[weak self] contactId in
                    
                    { self?.action.send(ContactsSectionViewModelAction.Contacts.ItemDidTapped(phone: contactId)) }
                })

            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .ui, message: "Fetching address book contacts list error: \(error.localizedDescription)")
            }
        }

        bind()
    }
    
    private func bind() {
        
        contacts
            .combineLatest(filter)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                let contacts = data.0
                let filter = data.1
                
                if contacts.isEmpty == false {
                    
                    withAnimation {
                        
                        visible = Self.reduce(items: contacts, filter: filter)
                    }
                    
                } else {
                    
                    withAnimation {
                        
                        visible = Array(repeating: ContactsPlaceholderItemView.ViewModel(style: .person), count: 8)
                    }
                }
                
            }.store(in: &bindings)
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                guard let selfPhone = data?.phone else {
                    return
                }
                
                withAnimation {
                    
                    selfContact = Self.reduceClientInfo(phone: selfPhone, phoneFormatter: phoneFormatter, action: { [weak self] phone in
                        
                        { self?.action.send(ContactsSectionViewModelAction.Contacts.ItemDidTapped(phone: phone)) }
                    })
                }
                
            }.store(in: &bindings)
        
        model.bankClientsInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] bankClients in
                
                guard let contactsViewModels = contacts.value as? [ContactsPersonItemView.ViewModel] else {
                    return
                }
                
                let bankClientsPhoneNumbers = bankClients.map{ $0.phone.digits }
                
                for contact in contactsViewModels {
                    
                    contact.isBankIcon = bankClientsPhoneNumbers.contains(contact.phone.digits) ? true : false
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Reducers

extension ContactsListSectionViewModel {
    
    static func reduce(items: [ContactsItemViewModel], filter: String?) -> [ContactsItemViewModel] {
        
        guard let filter = filter else {
            return items
        }
        
        let contacts = items.compactMap({ $0 as? ContactsPersonItemView.ViewModel })
        
        return contacts.filter({ contact in
            
            if let fullName = contact.name,
                fullName.localizedStandardContains(filter) || contact.phone.localizedCaseInsensitiveContains(filter) {
                
                return true
                
            } else {
                
                return false
            }
        })
    }
    
    static func reduce(addressBookContacts: [AddressBookContact], phoneFormatter: PhoneNumberFormaterProtocol, action: @escaping (AddressBookContact.ID) -> () -> Void) async -> [ContactsItemViewModel] {
    
        addressBookContacts.sorted(by: { first, second in
            
            guard let firstContactName = first.firstName?.lowercased(),
                  let secondContactName = second.firstName?.lowercased() else {
                return false
            }
            
            if firstContactName.localizedCaseInsensitiveCompare(secondContactName) == .orderedAscending {
                
                return firstContactName < secondContactName
                
            } else {
                
                return false
            }
            
        }).map({ contact in
            
            if let image = contact.avatar?.image {
                
                return ContactsPersonItemView.ViewModel(id: contact.id, icon: .image(image), name: contact.fullName, phone: contact.phone, isBankIcon: false, action: action(contact.id))

                
            } else if let initials = contact.initials {
                
                return ContactsPersonItemView.ViewModel(id: contact.id, icon: .initials(initials), name: contact.fullName, phone: contact.phone, isBankIcon: false, action: action(contact.id))
                
            } else {
                
                return ContactsPersonItemView.ViewModel(id: contact.id, icon: .placeholder, name: contact.fullName, phone: contact.phone, isBankIcon: false, action: action(contact.id))
            }
        })
    }
    
    static func reduceClientInfo(phone: String, phoneFormatter: PhoneNumberFormaterProtocol, action: @escaping (AddressBookContact.ID) -> () -> Void) -> ContactsPersonItemView.ViewModel {
   
        let formattedPhone = phoneFormatter.format(phone)
        
        return ContactsPersonItemView.ViewModel(id: phone, icon: .placeholder, name: "Себе", phone: formattedPhone, isBankIcon: false, action: action(phone))
    }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum Contacts {
        
        struct ItemDidTapped: Action {
            
            let phone: String
        }
    }
}
