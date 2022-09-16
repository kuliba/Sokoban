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
    @Published var searchBar: SearchBarComponent.ViewModel
    @Published var mode: Mode
    
    enum Mode {
        
        case contacts(LatestPaymentsViewComponent.ViewModel, ContactsListViewModel)
        case contactsSearch(ContactsListViewModel)
        case banks(TopBanksScetionType, [BanksListViewModel])
    }
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(_ model: Model, searchBar: SearchBarComponent.ViewModel, mode: Mode) {
        
        self.searchBar = searchBar
        self.model = model
        self.mode = mode
        
        bind()
    }
    
    convenience init(_ model: Model) {
        
        let contacts = Self.reduce(model: model, addressBookContact: model.contactsAgent.fetchContactsList())
        let searchBar: SearchBarComponent.ViewModel = .init(placeHolder: .contacts)
        self.init(model, searchBar: searchBar, mode: .contactsSearch(contacts))
    }
    
    //TODO: bind sections
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.LatestPayments.BanksList.Response:
                    
                    switch payload.result {
                    case .success(let banks):
                        self.mode = .banks(.banks(Self.reduce(model: model, banks: banks)), [Self.createCollapsebleViewModel(model)])
                        
                    case .failure(let error):
                        print(error)
                        break
                    }
                default: break
                }
            }.store(in: &bindings)
        
        model.latestPayments
            .combineLatest(model.latestPaymentsUpdating)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                let latestPayments = data.0
                
                let latestPaymentsFilterred = latestPayments.filter({ $0.type == .phone })
                
                withAnimation(.easeInOut(duration: 1)) {
                    
                    let contacts = Self.reduce(model: self.model, addressBookContact: model.contactsAgent.fetchContactsList())
                    let items = Self.itemsReduce(latest: latestPaymentsFilterred)
                    self.mode = .contacts(.init(items: items, model: model), contacts)
                }
                
            }.store(in: &bindings)
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                guard data != nil else {
                    self.model.action.send(ModelAction.ClientInfo.Fetch.Request())
                    return
                }
                
                let latestPaymentsFilterred = model.latestPayments.value.filter({ $0.type == .phone })
                
                withAnimation(.easeInOut(duration: 1)) {
                    
                    let contacts = Self.reduce(model: self.model, addressBookContact: model.contactsAgent.fetchContactsList())
                    let items = Self.itemsReduce(latest: latestPaymentsFilterred)
                    self.mode = .contacts(.init(items: items, model: model), contacts)
                }
                
            }.store(in: &bindings)
        
        //MARK: SearchViewModel
        
        searchBar.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                if data.digits.count >= 1 {
                    
                    withAnimation {
                        
                        self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: "89252798613"))
                        self.mode = .banks(.placeHolder, [Self.createCollapsebleViewModel(model)])
                    }
                } else {
                    
                    withAnimation(.easeInOut(duration: 1)) {
                        
                        let contacts = Self.reduce(model: self.model, addressBookContact: model.contactsAgent.fetchContactsList())
                        let items = Self.itemsReduce(latest: model.latestPayments.value.filter({ $0.type == .phone }))
                        self.mode = .contacts(.init(items: items, model: model), contacts)
                    }
                }
            }.store(in: &bindings)
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
    
    enum TopBanksScetionType {
        
        case banks(TopBanksViewModel)
        case placeHolder
    }
    
    class TopBanksViewModel {
        
        @Published var banks: [Bank]
        
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
    
    static func createCollapsebleViewModel(_ model: Model) -> BanksListViewModel {
        
        let allBanks = Self.reduceBanks(bankData: model.bankList.value)
        let banksListViewModel: BanksListViewModel = .init(bank: allBanks, optionViewModel: Self.createOptionViewModel(), mode: .normal(.init(icon: .ic24Bank, title: .otherBank, searchButton: nil, toggleButton: .init(icon: .ic24ChevronDown, action: {}), searchBar: nil)), isCollapsed: true)
        
        return banksListViewModel
    }
    
    static func createOptionViewModel() -> OptionSelectorView.ViewModel {
        
        let optionViewModel: OptionSelectorView.ViewModel = .init(options: [.init(id: "Российские", name: "Российские"), .init(id: "Иностранные", name: "Иностранные"), .init(id: "Все", name: "Все")], selected: "Иностранные", style: .template)
        return optionViewModel
    }
    
    class BanksListViewModel: ObservableObject, Hashable {
        
        let bank: [Bank]
        let optionViewModel: OptionSelectorView.ViewModel
        @Published var isCollapsed: Bool = false
        @Published var mode: Mode
        
        init(bank: [Bank], optionViewModel: OptionSelectorView.ViewModel, mode: Mode, isCollapsed: Bool) {
            
            self.bank = bank
            self.optionViewModel = optionViewModel
            self.mode = mode
            self.isCollapsed = isCollapsed
        }
        
        enum Mode {
            
            case normal(CollapsebleViewModel)
            case search(SearchBarComponent.ViewModel)
        }
        
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
        
        static func == (lhs: ContactsViewModel.BanksListViewModel, rhs: ContactsViewModel.BanksListViewModel) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(bank)
        }
    }
    
    struct CollapsebleViewModel {
        
        let icon: Image
        let title: Title
        let searchButton: ButtonViewModel?
        let toggleButton: ButtonViewModel
        var searchBar: SearchBarComponent.ViewModel?
        
        enum Title: String {
            
            case otherBank = "В другой банк"
            case abroad = "Переводы за рубеж"
        }
        
        struct ButtonViewModel {
            
            let icon: Image
            let action: () -> Void
        }
    }
    
    static func itemsReduce(latest: [LatestPaymentData]) -> [LatestPaymentsViewComponent.ViewModel.ItemViewModel] {
        
        var itemViewModel = [LatestPaymentsViewComponent.ViewModel.ItemViewModel]()
        
        itemViewModel = latest.map({LatestPaymentsViewComponent.ViewModel.ItemViewModel.latestPayment(.init(data: $0, model: .emptyMock, action: {}))})
        
        return itemViewModel
    }
    
    static func reduce(model: Model, addressBookContact: [AddressBookContact]) -> ContactsListViewModel {
        
        var contacts = [Contact]()
        
        contacts = addressBookContact.map({ Contact(fullName: $0.fullName, image: $0.avatar?.image, phone: $0.phone, icon: nil, action: {
            print("contact")
        })})
        
        contacts = contacts.sorted(by: {
            guard let contact = $0.fullName, let secondContact = $1.fullName else {
                return false
            }
            return contact < secondContact
        })
        if let phone = model.clientInfo.value?.phone {
            
            let phoneFormatter = PhoneNumberFormater()
            let formattedPhone = phoneFormatter.format(phone)
            
            let selfContact: Contact = .init(fullName: "Себе", image: nil, phone: formattedPhone, icon: nil, action: {
                
                print("selfContact")
            })
            
            let contactsViewModel = ContactsListViewModel(selfContact: selfContact, contacts: contacts)
            return contactsViewModel
        }
        
        let contactsViewModel = ContactsListViewModel(selfContact: nil, contacts: contacts)
        return contactsViewModel
    }
    
    static func reduceBanks(bankData: [BankData]) -> [BanksListViewModel.Bank] {
        
        var banks = [BanksListViewModel.Bank]()
        
        banks = bankData.map({BanksListViewModel.Bank.init(title: $0.memberNameRus, image: $0.svgImage.image, action: {})})
        banks = banks.sorted(by: {$0.title < $1.title})
        
        return banks
    }
    
    static func reduce(model: Model, banks: [PaymentPhoneData]) -> TopBanksViewModel {
        
        let topBanksViewModel: TopBanksViewModel = .init(banks: [])
        
        //TODO: set name
        let banks = banks.map({TopBanksViewModel.Bank(image: getImageBank(model: model, paymentBank: $0), favorite: $0.defaultBank, name: nil, bankName: $0.bankName, action: {})})
        
        topBanksViewModel.banks = banks
        
        func getImageBank(model: Model, paymentBank: PaymentPhoneData) -> Image? {
            
            let banks = model.bankList.value
            for bank in banks {
                
                if paymentBank.bankId == bank.memberId {
                    
                    return bank.svgImage.image
                }
            }
            
            return nil
        }
        
        return topBanksViewModel
    }
}

enum ContactsViewModelAction {
    
    struct SetupPhoneNumber: Action {
        
        let phone: String
    }
}

extension ContactsViewModel {
    
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .contactsSearch(.init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .contacts(.init(items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))], model: .emptyMock), .init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleBanks: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .banks(.banks(.init(banks: [.init(image: nil, favorite: false, name: "Юрка Б.", bankName: "ЛокоБанк", action: {}), .init(image: nil, favorite: true, name: "Юрка Б.", bankName: "Сбербанк", action: {}), .init(image: nil, favorite: false, name: nil, bankName: "Тинькофф", action: {})])), [.init(bank: [.init(title: "Эвокабанк", image: nil, action: {}), .init(title: "Ардшидбанк", image: nil, action: {}), .init(title: "IDBank", image: nil, action: {})], optionViewModel: .init(options: [.init(id: "Российские", name: "Российские"), .init(id: "Иностранные", name: "Иностранные"), .init(id: "Все", name: "Все")], selected: "Иностранные", style: .template), mode: .normal(.init(icon: .ic24Bank, title: .otherBank, searchButton: nil, toggleButton: .init(icon: .ic24ChevronDown, action: {}), searchBar: nil)), isCollapsed: true)]))
}
