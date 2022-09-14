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
    let searchBar: SearchBarComponent.ViewModel
    @Published var mode: Mode
    
    enum Mode {
        
        case contacts(LatestPaymentsViewComponent.ViewModel, ContactsListViewModel)
        case contactsSearch(ContactsListViewModel)
        case banks(String, TopBanksViewModel, BanksListViewModel)
    }
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(_ model: Model, searchBar: SearchBarComponent.ViewModel, mode: Mode) {
        
        self.searchBar = searchBar
        self.model = model
        self.mode = mode
    }
    
    convenience init(_ model: Model) {

        let contacts = Self.reduce(addressBookContact: model.contactsAgent.fetchContactsList())
        let searchBar: SearchBarComponent.ViewModel = .init(placeHolder: .contacts)
        self.init(model, searchBar: searchBar, mode: .contactsSearch(contacts))
    }
    
    private func bind() {
        
        model.clientInfo
            .combineLatest(model.clientInfo)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                let clientInfo = data.0
                
                if let phone = clientInfo?.phone {
                    
                    withAnimation(.easeInOut(duration: 1)) {
//                        self.selfContact = .init(fullName: "Себе", image: nil, phone: phone, icon: nil, action: {
//
//                            self.searchBar.text = phone.description
//                        })
                        
                    }
                }
                
            }.store(in: &bindings)
        
        model.clientPhoto
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientPhotoData in
                
                if let photoData = clientPhotoData?.photo, let image = photoData.image{
                    
//                    self.selfContact?.image = image
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
        
        //MARK: SearchViewModel
        
//        searchViewModel.$text
//            .receive(on: DispatchQueue.main)
//            .sink { [unowned self] data in
//
//                if data.digits.count == 9 {
//
//                    self.listState = .banks
//                }
//            }.store(in: &bindings)
    }
    
    class ContactsListViewModel: ObservableObject {
        
        @Published var selfContact: Contact?
        @Published var contacts: [Contact]
        
        init(selfContact: Contact?, contacts: [Contact]) {
            
            self.selfContact = selfContact
            self.contacts = contacts
        }
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
        
        static func == (lhs: Contact, rhs: Contact) -> Bool {
            
            lhs.fullName == rhs.fullName && lhs.phone == rhs.phone
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(phone)
        }
    }
    
    class TopBanksViewModel {
        
        let banks: [Bank]
        
        internal init(banks: [ContactsViewModel.TopBanksViewModel.Bank]) {
            self.banks = banks
        }
        
        struct Bank: Identifiable, Hashable {
         
            let id = UUID()
            let image: Image?
            let favorite: Bool
            let name: String?
            let bankName: String
            let action: () -> Void
            
            internal init(image: Image?, favorite: Bool, name: String?, bankName: String, action: @escaping () -> Void) {
                
                self.image = image
                self.name = name
                self.favorite = favorite
                self.bankName = bankName
                self.action = action
            }
            
            static func == (lhs: Bank, rhs: Bank) -> Bool {
                lhs.name == rhs.name && lhs.id == rhs.id
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(name)
            }
        }
    }
    
    struct BanksListViewModel {
        
        let bank: [Bank]
        
        class Bank: Hashable, Identifiable {
            
            let id = UUID()
            let title: String
            let image: Image?
            let action: () -> Void
            
            internal init(title: String, image: Image?, action: @escaping () -> Void) {
                
                self.title = title
                self.image = image
                self.action = action
            }
            
            static func == (lhs: Bank, rhs: Bank) -> Bool {
                lhs.id == rhs.id && lhs.title == rhs.title
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(title)
            }
        }
    }
    
    static func reduce(addressBookContact: [AddressBookContact]) -> ContactsListViewModel {
        
        var contacts = [Contact]()
        
        contacts = addressBookContact.map({ Contact(fullName: $0.fullName, image: $0.avatar?.image, phone: $0.phone, icon: nil, action: {} )})
        
        contacts = contacts.sorted(by: {
            guard let contact = $0.fullName, let secondContact = $1.fullName else {
                return false
            }
            return contact < secondContact
        })
        
        let contactsViewModel = ContactsListViewModel(selfContact: nil, contacts: contacts)
        return contactsViewModel
    }
    
    static func reduceBanks(bankData: [BankData]) -> [BanksListViewModel.Bank] {
        
        var banks = [BanksListViewModel.Bank]()
        
        banks = bankData.map({BanksListViewModel.Bank.init(title: $0.memberNameRus, image: $0.svgImage.image, action: {})})
        
        return banks
    }
}

extension ContactsViewModel {
    
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .contactsSearch(.init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .contacts(.init(items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))], model: .emptyMock), .init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleBanks: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .banks("phone", .init(banks: [.init(image: nil, favorite: false, name: "Юрка Б.", bankName: "ЛокоБанк", action: {}), .init(image: nil, favorite: true, name: "Юрка Б.", bankName: "Сбербанк", action: {}), .init(image: nil, favorite: false, name: nil, bankName: "Тинькофф", action: {})]), .init(bank: [.init(title: "Эвокабанк", image: nil, action: {}), .init(title: "Ардшидбанк", image: nil, action: {}), .init(title: "IDBank", image: nil, action: {})])))
}
