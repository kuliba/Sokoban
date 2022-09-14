//
//  ContactsViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import Foundation
import SwiftUI
import Combine

class ContactsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let title = "Выберите контакт"
    let contacts: [Contact]
    let searchViewModel: SearchBarComponent.ViewModel
    let topListViewModel: [TopListViewModel]?
    @Published var selfContact: Contact?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(_ model: Model, searchViewModel: SearchBarComponent.ViewModel, topListViewModel: [TopListViewModel]?) {
        
        self.model = model
        self.searchViewModel = searchViewModel
        let contacts = Self.reduce(addressBookContact: model.contactsAgent.fetchContactsList())
        self.contacts = contacts
        self.selfContact = nil
        self.topListViewModel = topListViewModel
        
        if model.clientInfo.value == nil {
            
            self.model.action.send(ModelAction.ClientInfo.Fetch.Request())
        }
        
        bind()
    }
    
    init(_ model: Model, contacts: [AddressBookContact], searchViewModel: SearchBarComponent.ViewModel, selfContact: Contact?, topListViewModel: [TopListViewModel]?) {
        
        self.model = model
        self.searchViewModel = searchViewModel
        self.contacts = Self.reduce(addressBookContact: contacts)
        self.selfContact = selfContact
        self.topListViewModel = topListViewModel
    }
    
    private func bind() {

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case let payload as ModelAction.OwnerPhone.Response:
                    
                    switch payload {
                    case let .success(phone):
                        
                        for contact in contacts {
                            if contact.phone == phone {
                        
                                withAnimation {
                                    
                                    contact.icon = Image("foraContactImage")
                                }
                            }
                        } 
                    }
                    
                default: break
                }
            }.store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientInfo)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                let clientInfo = data.0
                
                if let phone = clientInfo?.phone {
                    
                    withAnimation(.easeInOut(duration: 1)) {
                        self.selfContact = .init(fullName: "Себе", image: nil, phone: phone, icon: nil, action: {
                            
                            self.searchViewModel.text = phone.description
                        })
                        
                    }
                }
                
            }.store(in: &bindings)
        
        model.clientPhoto
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientPhotoData in
                
                if let photoData = clientPhotoData?.photo, let image = photoData.image{
                    
                    self.selfContact?.image = image
                }
                
            }.store(in: &bindings)
        
        model.latestPayments
            .combineLatest(model.latestPaymentsUpdating)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                let latestPayments = data.0
                
                let latestPaymentsFilterred = latestPayments.filter({ $0.type == .phone })
                
                withAnimation(.easeInOut(duration: 1)) {
                    
                    //TODO: reduce last payments
                }
                
            }.store(in: &bindings)
    }
    
    class Contact: ObservableObject, Identifiable, Hashable {
        
        let id = UUID()
        let fullName: String?
        let phone: String
        var image: Image?
        @Published var icon: Image?
        let action: () -> Void
        
        internal init(fullName: String?, image: Image?, phone: String, icon: Image?, action: @escaping () -> Void) {
            
            self.phone = phone
            self.fullName = fullName
            self.image = image
            self.icon = icon
            self.action = action
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
        
        contacts = addressBookContact.map({ Contact(fullName: $0.fullName, image: $0.avatar?.image, phone: $0.phone, icon: nil, action: {} )})
        
        contacts = contacts.sorted(by: {
            guard let contact = $0.fullName, let secondContact = $1.fullName else {
                return false
            }
            return contact < secondContact
        })
        
        return contacts
    }
}

extension ContactsViewModel {
    
    static let sample: ContactsViewModel = .init(.emptyMock, contacts: [.init(phone: "+7 925 279 86 13", firstName: "Иван", middleName: "Иванович", lastName: "Иванов", avatar: nil), .init(phone: "+7 925 279 86 13", firstName: "Иван", middleName: "Иванович", lastName: "Иванов", avatar: nil)], searchViewModel: .init(placeHolder: .contacts), selfContact: .init(fullName: "Себе", image: nil, phone: "+7 925 279 86 13", icon: nil, action: {}), topListViewModel: [.init(image: nil, name: "+7 925 279 86 13", description: nil)])
    
    static let emptyNameSample: ContactsViewModel = .init(.emptyMock, contacts: [.init(phone: "+7 925 279 86 13", firstName: nil, middleName: nil, lastName: nil, avatar: nil), .init(phone: "+7 925 279 86 13", firstName: "Иван", middleName: "Иванович", lastName: "Иванов", avatar: nil)], searchViewModel: .init(isEditing: true, placeHolder: .contacts), selfContact: nil, topListViewModel: nil)
}
