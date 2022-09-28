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
        case contactsSearch(ContactsListViewModel?)
        case banks(TopBanksScetionType, [BanksListViewModel])
        case banksSearch([BanksListViewModel])
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
        
        let searchBar: SearchBarComponent.ViewModel = .init(model, placeHolder: .contacts)
        self.init(model, searchBar: searchBar, mode: .contactsSearch(nil))
        let contacts = self.reduce(model: model, addressBookContact: model.contactsAgent.fetchContactsList())
        self.init(model, searchBar: searchBar, mode: .contactsSearch(contacts))
    }
    
    //TODO: bind sections
        
    func bindCategorySelector(_ sections: [BanksListViewModel]) {

        for section in sections {

            section.optionViewModel?.action
                .receive(on: DispatchQueue.main)
                .sink{ [unowned self] action in

                    switch action {
                    case let payload as OptionSelectorAction.OptionDidSelected:
                    
                        section.optionViewModel?.selected = payload.optionId
                        section.bank = Self.reduceBanks(bankData: model.bankList.value, filterByType: BanksTypes(rawValue: section.optionViewModel?.selected ?? "Российские"))
                        
                        if section.optionViewModel?.selected == "Российские" {
                            
                            section.mode = .normal(.init(icon: .ic40SBP, title: .otherBank, searchButton: .init(icon: .ic24Search, action: {
                                let bankList = [Self.openCreateCollapsebleViewModel(self.model, filter: nil)]
                                self.mode = .banksSearch(bankList)
                            }), toggleButton: .init(icon: .ic16ChevronUp, action: {})))
                        } else {
                            
                            section.mode = .normal(.init(icon: .ic24Bank, title: .otherBank, searchButton: nil, toggleButton: .init(icon: .ic24ChevronDown, action: {}), searchBar: nil))
                        }
                    default: break
                    }

                }.store(in: &bindings)
        }
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                
                case let payload as ContactsViewModelAction.SetupPhoneNumber:
                    self.searchBar.text = payload.phone
                    
                default: break
                }
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.LatestPayments.BanksList.Response:
                    
                    switch payload.result {
                    case .success(let banks):

                        if let banks = reduce(model: model, banks: banks) {

                            
                            var bankList = [Self.createCollapsebleViewModel(model)]
                            
                            if self.searchBar.text.digits.hasPrefix("374") {
                                
                                bankList.append(Self.createCountryCollapsebleViewModel(model))
                            }
                            
                            self.mode = .banks(.banks(banks), bankList)
                            bindCategorySelector(bankList)
                            
                        }
                        
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
                    
                    let contacts = reduce(model: self.model, addressBookContact: model.contactsAgent.fetchContactsList())
                    let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                    self.mode = .contacts(.init(titleHidden: true, items: items, model: model), contacts)
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
                    
                    let contacts = reduce(model: self.model, addressBookContact: model.contactsAgent.fetchContactsList())
                    let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                    self.mode = .contacts(.init(titleHidden: true, items: items, model: model), contacts)
                }
                
            }.store(in: &bindings)

        //MARK: SearchViewModel
        
        searchBar.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                if data.digits.count >= 9 {
                    
                    withAnimation {
                        
                        self.searchBar.textColor = .mainColorsBlack
                        self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: data.digits))
                        let bankList = [Self.createCollapsebleViewModel(model)]
                        bindCategorySelector(bankList)
                        self.mode = .banks(.placeHolder, bankList)
                    }
                } else if data.digits.count >= 1 {
                    
                    withAnimation {
                        
                        self.searchBar.textColor = .mainColorsBlack
                        let contacts = reduce(model: self.model, addressBookContact: model.contactsAgent.fetchContactsList(), filter: data)
                        contacts.selfContact = nil
                        self.mode = .contactsSearch(contacts)
                    }
                } else {
                    
                    withAnimation {
                        self.searchBar.textColor = .textPlaceholder
                        let latestPaymentsFilterred = model.latestPayments.value.filter({$0.type == .phone})
                        
                        let contacts = reduce(model: self.model, addressBookContact: model.contactsAgent.fetchContactsList())
                        let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                        self.mode = .contacts(.init(titleHidden: true, items: items, model: model), contacts)
                    }
                }
                
                if data.digits.hasPrefix("374"), data.digits.count >= 9 {
                
                    self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: data.digits))
                    let bankList = [Self.createCollapsebleViewModel(model), Self.createCountryCollapsebleViewModel(model)]
                    bindCategorySelector(bankList)
                    self.mode = .banks(.placeHolder, bankList)
                }
                
            }.store(in: &bindings)
    }
    
    class ContactsListViewModel: ObservableObject {
        
        @Published var selfContact: ContactViewModel?
        @Published var contacts: [ContactViewModel]
        
        init(selfContact: ContactViewModel?, contacts: [ContactViewModel]) {
            
            self.selfContact = selfContact
            self.contacts = contacts
        }
    }
    
    class ContactViewModel: ObservableObject, Identifiable, Hashable {
        
        let id = UUID()
        let fullName: String?
        let phone: String
        var image: IconImage?
        @Published var icon: Image?
        let action: () -> Void
        
        internal init(fullName: String?, image: IconImage?, phone: String, icon: Image?, action: @escaping () -> Void) {
            
            self.phone = phone
            self.fullName = fullName
            self.image = image
            self.icon = icon
            self.action = action
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
            let defaultBank: Bool
            let name: String?
            let bankName: String
            let action: () -> Void
            
            internal init(image: Image?, defaultBank: Bool, name: String?, bankName: String, action: @escaping () -> Void) {
                
                self.image = image
                self.name = name
                self.defaultBank = defaultBank
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
        
        let options = Self.createOptionViewModel()
        let banks = Self.reduceBanks(bankData: model.bankList.value, filterByType: BanksTypes(rawValue: options.selected))
        let banksListViewModel: BanksListViewModel = .init(bank: banks, optionViewModel: options, mode: .normal(.init(icon: .ic40SBP, title: .otherBank, searchButton: .init(icon: .ic24Search, action: {}), toggleButton: .init(icon: .ic16ChevronUp, action: {}))), isCollapsed: false)

        return banksListViewModel
    }
    
    static func createCountryCollapsebleViewModel(_ model: Model) -> BanksListViewModel {
        
        let banks = Self.reduceCountry(bankData: model.countriesList.value)
        let banksListViewModel: BanksListViewModel = .init(bank: banks, optionViewModel: nil, mode: .normal(.init(icon: .init("abroad"), title: .abroad, searchButton: nil, toggleButton: .init(icon: .ic16ChevronUp, action: {}))), isCollapsed: false)

        return banksListViewModel
    }
    
    static func openCreateCollapsebleViewModel(_ model: Model, filter: String? = nil) -> BanksListViewModel {
        
        let options = Self.createOptionViewModel()
        let banks = Self.reduceBanks(bankData: model.bankList.value, filterByType: BanksTypes(rawValue: options.selected), filterByName: filter)
        let banksListViewModel: BanksListViewModel = .init(bank: banks, optionViewModel: options, mode: .search(.init(model, placeHolder: .banks)), isCollapsed: true)

        return banksListViewModel
    }
    
    static func createOptionViewModel() -> OptionSelectorView.ViewModel {
        
        let options = BanksTypes.allCases.map({Option(id: $0.rawValue, name: $0.rawValue)})
        guard let firstOption = options.first?.id else {
            let optionViewModel: OptionSelectorView.ViewModel = .init(options: options, selected: "", style: .template, mode: .action)
            return  optionViewModel }
        
        let optionViewModel: OptionSelectorView.ViewModel = .init(options: options, selected: firstOption, style: .template, mode: .action)
        return optionViewModel
    }
    
    class BanksListViewModel: ObservableObject, Hashable {

        @Published var bank: [Bank]
        @Published var optionViewModel: OptionSelectorView.ViewModel?
        @Published var isCollapsed: Bool = false
        @Published var mode: Mode

        init(bank: [Bank], optionViewModel: OptionSelectorView.ViewModel?, mode: Mode, isCollapsed: Bool) {
            
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
            let bankType: BanksTypes?
            let action: () -> Void
            
            internal init(title: String, image: Image?, bankType: BanksTypes?, action: @escaping () -> Void) {
                
                self.title = title
                self.image = image
                self.bankType = bankType
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
    
    func itemsReduce(model: Model, latest: [LatestPaymentData]) -> [LatestPaymentsViewComponent.ViewModel.ItemViewModel] {
        
        var itemViewModel = [LatestPaymentsViewComponent.ViewModel.ItemViewModel]()
        
        itemViewModel = latest.map({ latestPayment in
            
            if let latestPhone = latestPayment as? PaymentGeneralData {
                
                return LatestPaymentsViewComponent.ViewModel.ItemViewModel.latestPayment(.init(data: latestPayment, model: model, action: { [weak self] in
                     
                    self?.action.send(ContactsViewModelAction.SetupPhoneNumber(phone: latestPhone.phoneNumber))
                 }))
            }
            
            return LatestPaymentsViewComponent.ViewModel.ItemViewModel.latestPayment(.init(data: latestPayment, model: model, action: {}))
        })
        
        return itemViewModel
    }
    
    func reduce(model: Model, addressBookContact: [AddressBookContact], filter: String? = nil) -> ContactsListViewModel {
        
        var contacts = [ContactViewModel]()
        
         contacts = addressBookContact.map({ contact in
             
             let icon = self.model.bankClientInfo.value.contains(where: {$0?.phone == contact.phone}) ? Image("foraContactImage") : nil
             
             if let image = contact.avatar?.image {
                 
                 return ContactViewModel(fullName: contact.fullName, image: .image(image), phone: contact.phone, icon: icon, action: { [weak self] in
                     
                     self?.action.send(ContactsViewModelAction.SetupPhoneNumber(phone: contact.phone))
                 })
             } else if let initials = model.contact(for: contact.phone)?.initials {
                 
                 return ContactViewModel(fullName: contact.fullName, image: .initials(initials), phone: contact.phone, icon: icon, action: { [weak self] in
                     
                     self?.action.send(ContactsViewModelAction.SetupPhoneNumber(phone: contact.phone))
                 })
             } else {
                 return ContactViewModel(fullName: contact.fullName, image: nil, phone: contact.phone, icon: icon, action: { [weak self] in
                     
                     self?.action.send(ContactsViewModelAction.SetupPhoneNumber(phone: contact.phone))
                 })
             }
         })
        
        contacts = contacts.sorted(by: {
            guard let contact = $0.fullName, let secondContact = $1.fullName else {
                return false
            }
            return contact < secondContact
        })
        
        if let filter = filter {
            
            contacts = contacts.filter({ contact in
                
                if let fullName = contact.fullName, fullName.localizedStandardContains(filter) || contact.phone.localizedCaseInsensitiveContains(filter) {
                    return true
                    
                } else {
                    
                    return false
                }
            })
        }
        
        if let phone = model.clientInfo.value?.phone {
            
            let phoneFormatter = PhoneNumberFormater()
            let formattedPhone = phoneFormatter.format(phone)
            
            let selfContact: ContactViewModel = .init(fullName: "Себе", image: nil, phone: formattedPhone, icon: nil, action: { [weak self] in self?.action.send(ContactsViewModelAction.SetupPhoneNumber(phone: phone))})
            
            let contactsViewModel = ContactsListViewModel(selfContact: selfContact, contacts: contacts)
            return contactsViewModel
        }
        
        let contactsViewModel = ContactsListViewModel(selfContact: nil, contacts: contacts)
        return contactsViewModel
    }
    
    static func reduceBanks(bankData: [BankData], filterByType: BanksTypes? = nil, filterByName: String? = nil) -> [BanksListViewModel.Bank] {
        
        var banks = [BanksListViewModel.Bank]()
        
        banks = bankData.map({BanksListViewModel.Bank.init(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.banksType, action: {})})
        banks = banks.sorted(by: {$0.title < $1.title})
        
        if let filter = filterByType, filter != .all {
            banks = banks.filter({$0.bankType == filter})
        }
        
        if let filter = filterByName {
            
            banks = banks.filter({ bank in
                
                if bank.title.localizedStandardContains(filter) {
                    return true
                } else {
                    return false
                }
            })
        }
        
        return banks
    }
    
    static func reduceCountry(bankData: [CountryData]) -> [BanksListViewModel.Bank] {
        
        var banks = [BanksListViewModel.Bank]()
        let bankData2 = bankData.filter({$0.paymentSystemIdList.contains("DIRECT")})
        banks = bankData2.map({BanksListViewModel.Bank.init(title: $0.name, image: $0.svgImage?.image, bankType: nil, action: {})})
        banks = banks.sorted(by: {$0.title < $1.title})
                
        return banks
    }
    
    func reduce(model: Model, banks: [PaymentPhoneData]) -> TopBanksViewModel? {
        
        let topBanksViewModel: TopBanksViewModel = .init(banks: [])

        var banksList: [TopBanksViewModel.Bank] = []
        
        let banksListMapped = banks.map({
            
            if let bankName = $0.bankName, let defaultBank = $0.defaultBank, let payment = $0.payment {
               
                let contact = payment ? model.contact(for: self.searchBar.text) : nil
                banksList.append(TopBanksViewModel.Bank(image: getImageBank(model: model, paymentBank: $0), defaultBank: defaultBank, name: contact?.fullName, bankName: bankName, action: {
                    
                }))
                
            } else {
                
                return
            }
        })
        
        topBanksViewModel.banks = banksList
        
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
    
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(.emptyMock, placeHolder: .contacts), mode: .contactsSearch(.init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(.emptyMock, placeHolder: .contacts), mode: .contacts(.init(titleHidden: true, items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))], model: .emptyMock), .init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleBanks: ContactsViewModel = .init(.emptyMock, searchBar: .init(.emptyMock, placeHolder: .contacts), mode: .banks(.banks(.init(banks: [.init(image: nil, defaultBank: false, name: "Юрка Б.", bankName: "ЛокоБанк", action: {}), .init(image: nil, defaultBank: true, name: "Юрка Б.", bankName: "Сбербанк", action: {}), .init(image: nil, defaultBank: false, name: nil, bankName: "Тинькофф", action: {})])), [.init(bank: [.init(title: "Эвокабанк", image: nil, bankType: nil, action: {}), .init(title: "Ардшидбанк", image: nil, bankType: nil, action: {}), .init(title: "IDBank", image: nil, bankType: nil, action: {})], optionViewModel: .init(options: [.init(id: "Российские", name: "Российские"), .init(id: "Иностранные", name: "Иностранные"), .init(id: "Все", name: "Все")], selected: "Иностранные", style: .template), mode: .normal(.init(icon: .ic24Bank, title: .otherBank, searchButton: nil, toggleButton: .init(icon: .ic24ChevronDown, action: {}), searchBar: nil)), isCollapsed: true)]))
}
