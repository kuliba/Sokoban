//
//  ContactsListViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import SwiftUI
import Combine

class ContactsListViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var selfContact: ContactViewModel?
    @Published var contacts: [ContactViewModel]
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
        
    init(_ model: Model, selfContact: ContactViewModel?, contacts: [ContactViewModel]) {
        
        self.model = model
        self.selfContact = selfContact
        self.contacts = contacts
    }
    
    convenience init(_ model: Model, filterText: String? = nil) {
        
        self.init(model, selfContact: nil, contacts: [])
        
        if let addressBookContact = try? model.contactsAgent.fetchContactsList() {
            
            self.contacts = self.reduce(addressBookContact: addressBookContact, filterText: filterText)
        }
        
        if let phone = model.clientInfo.value?.phone {
            
            let selfContact = self.reduceClientInfo(phone: phone)
            
            self.selfContact = selfContact
        }
        
        bind()
    }
    
    func bind() {
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                guard let phone = data?.phone else {
                    return
                }
                
                self.selfContact = reduceClientInfo(phone: phone)
                
            }.store(in: &bindings)
    }
    
    func reduce(addressBookContact: [AddressBookContact], filterText: String?) -> [ContactViewModel] {
        
        var contacts = [ContactViewModel]()
        var adressBookSorted = addressBookContact
        
        adressBookSorted.sort(by: {
            
            guard let contact = $0.firstName?.lowercased(), let secondContact = $1.firstName?.lowercased() else {
                return false
            }
            
            if contact.localizedCaseInsensitiveCompare(secondContact) == .orderedAscending {
                return contact < secondContact
                
            } else {
                return false
            }
        })
        
        contacts = adressBookSorted.map({ [unowned self] contact in
            
            let icon = self.model.bankClientInfo.value.contains([BankClientInfo(name: "", phone: contact.phone)]) ? Image("foraContactImage") : nil
            
            if let image = contact.avatar?.image {
                return ContactViewModel(fullName: contact.fullName, image: .image(image), phone: contact.phone, icon: icon, actionContact: { [weak self] in self?.action.send(ContactsListViewModelAction.ContactSelect(phone: contact.phone))})
                
            } else if let initials = self.model.contact(for: contact.phone)?.initials {
                return ContactViewModel(fullName: contact.fullName, image: .initials(initials), phone: contact.phone, icon: icon, actionContact: { [weak self] in self?.action.send(ContactsListViewModelAction.ContactSelect(phone: contact.phone))})
                
            } else {
                return ContactViewModel(fullName: contact.fullName, image: nil, phone: contact.phone, icon: icon, actionContact: { [weak self] in self?.action.send(ContactsListViewModelAction.ContactSelect(phone: contact.phone))})
            }
        })
        
        contacts = contacts.sorted(by: { firstContact, secondContact in
            guard let firstFullName = firstContact.fullName, let secondFullName = secondContact.fullName else {
                return true
            }
            
            return firstFullName.localizedCaseInsensitiveCompare(secondFullName) == .orderedAscending
        })
        
        if let filter = filterText {
            
            contacts = contacts.filter({ contact in
                
                if let fullName = contact.fullName, fullName.localizedStandardContains(filter) || contact.phone.localizedCaseInsensitiveContains(filter) {
                    return true
                    
                } else {
                    
                    return false
                }
            })
        }
        
        return contacts
    }
    
    func reduceClientInfo(phone: String) -> ContactViewModel {
        
        let phoneFormatter = PhoneNumberKitFormater()
        let formattedPhone = phoneFormatter.format(phone)
        
        let selfContact: ContactViewModel = .init(fullName: "Себе", image: nil, phone: formattedPhone, icon: nil, actionContact: { [weak self] in self?.action.send(ContactsViewModelAction.SetupPhoneNumber(phone: phone))   
        })
        
        return selfContact
    }
    
    class ContactViewModel: ObservableObject, Identifiable, Hashable {
        
        let id = UUID()
        let fullName: String?
        let phone: String
        var image: IconImage?
        @Published var icon: Image?
        let actionContact: () -> Void
        
        init(fullName: String?, image: IconImage?, phone: String, icon: Image?, actionContact: @escaping () -> Void) {
            
            self.phone = phone
            self.fullName = fullName
            self.image = image
            self.icon = icon
            self.actionContact = actionContact
        }
        
        enum IconImage {
            
            case image(Image)
            case initials(String)
        }
        
        static func == (lhs: ContactViewModel, rhs: ContactViewModel) -> Bool {
            
            lhs.fullName == rhs.fullName && lhs.phone == rhs.phone
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(phone)
            hasher.combine(fullName)
        }
    }
}

struct ContactsListViewModelAction {
    
    struct ContactSelect: Action {
        
        let phone: String
    }
}
