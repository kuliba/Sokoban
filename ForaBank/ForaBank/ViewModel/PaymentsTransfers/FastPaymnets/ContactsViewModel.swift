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
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    enum Mode {
        
        case contacts(LatestPaymentsViewComponent.ViewModel?, ContactsListViewModel)
        case contactsSearch(ContactsListViewModel?)
        case banks(TopBanksSectionType?, [CollapsableViewModel])
        case banksSearch([CollapsableViewModel])
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
        
        let searchBar: SearchBarComponent.ViewModel = .init(placeHolder: .contacts)
        self.init(model, searchBar: searchBar, mode: .contacts(nil, ContactsViewModel.ContactsListViewModel.init(selfContact: nil, contacts: [])))
        let contacts = self.reduce(model: model)
        self.mode = .contacts(nil, contacts)
    }
    
    //TODO: bind sections
    
    func bindCategorySelector(_ sections: [CollapsableViewModel]) {
        
        for section in sections {
            
            section.options?.action
                .receive(on: DispatchQueue.main)
                .sink{[unowned self] action in
                    
                    switch action {
                    case let payload as OptionSelectorAction.OptionDidSelected:
                        
                        section.options?.selected = payload.optionId
                        
                        if payload.optionId != "Российские" {
                            
                            section.items = .init(self.model, type: .banks(.direct))
                            section.header.icon = .ic24Bank
                            
                        } else {
                            
                            section.items = .init(self.model, type: .banks(.sfp))
                            section.header.icon = .ic40SBP
                        }
                        
                    default: break
                    }
                    
                }.store(in: &bindings)
            
            section.searchBar.$text
                .receive(on: DispatchQueue.main)
                .sink{ [unowned self] text in
                    
                    section.items = .init(self.model, type: .banks(.sfp), filterText: text)
                    
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
                            
                            //                            let bankList = Self.createCollapsebleViewModel(model)
                            
                            //                            bindCategorySelector(bankList)
                            //                            self.mode = .banks(.banks(banks), bankList)
                            
                        }
                        
                    case .failure:
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
                    
                    let contacts = reduce(model: self.model)
                    let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                    self.mode = .contacts(.init(model, items: items), contacts)
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
                    
                    let contacts = reduce(model: self.model)
                    let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                    self.mode = .contacts(.init(model, items: items), contacts)
                }
                
            }.store(in: &bindings)
        
        //MARK: SearchViewModel
        
        searchBar.$isValidation
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isValidation in
                
                if isValidation {
                    
                    withAnimation {
                        
                        self.feedbackGenerator.notificationOccurred(.success)
                        
                        self.searchBar.textColor = .mainColorsBlack
                        self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: self.searchBar.text))
                        
                        let collapsable: [CollapsableViewModel] = [.init(model, kind: .banks(.sfp)), .init(model, kind: .country)]
                        
                        self.mode = .banks(.placeHolder, collapsable)
                        bindCategorySelector(collapsable)
                    }
                }
                
            }.store(in: &bindings)
        
        searchBar.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                if text.count >= 1 {
                    
                    withAnimation {
                        
                        self.searchBar.textColor = .mainColorsBlack
                        let contacts = reduce(model: self.model, filter: text)
                        contacts.selfContact = nil
                        self.mode = .contactsSearch(contacts)
                    }
                } else {
                    
                    withAnimation {
                        self.searchBar.textColor = .textPlaceholder
                        let latestPaymentsFilterred = model.latestPayments.value.filter({$0.type == .phone})
                        
                        let contacts = reduce(model: self.model)
                        let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                        self.mode = .contacts(.init(model, items: items), contacts)
                    }
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
    
    enum TopBanksSectionType {
        
        case banks(TopBanksViewModel)
        case placeHolder
    }
    
    class TopBanksViewModel {
        
        @Published var banks: [Bank]
        
        internal init(banks: [Bank]) {
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
    
    class ItemsListViewModel: ObservableObject, Hashable, Identifiable {
        
        let id = UUID()
        @Published var items: [Item]
        
        init(items: [Item]) {
            
            self.items = items
        }
        
        convenience init(_ model: Model, type: Kind, filterText: String? = nil) {
            
            switch type {
                
            case let .banks(bankType):
                let items = Self.reduceBanks(model, filterByType: bankType, filterByName: filterText)
                self.init(items: items)
                
            case .country:
                let items = Self.reduceCountry(model)
                self.init(items: items)
            }
        }
        
        class Item: Hashable, Identifiable {
            
            let id = UUID()
            let title: String
            let image: Image?
            let bankType: BankType?
            let action: () -> Void
            
            internal init(title: String, image: Image?, bankType: BankType?, action: @escaping () -> Void) {
                
                self.title = title
                self.image = image
                self.bankType = bankType
                self.action = action
            }
            
            static func == (lhs: Item, rhs: Item) -> Bool {
                lhs.id == rhs.id && lhs.title == rhs.title
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(title)
            }
        }
        
        static func == (lhs: ContactsViewModel.ItemsListViewModel, rhs: ContactsViewModel.ItemsListViewModel) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(items)
        }
        
        static func reduceBanks(_ model: Model, filterByType: BankType? = nil, filterByName: String? = nil) -> [ItemsListViewModel.Item] {
            
            let bankData = model.bankList.value
            var banks = [ItemsListViewModel.Item]()
            
            banks = bankData.map({ItemsListViewModel.Item.init(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
            banks = banks.sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
            banks = banks.sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
            
            if let filter = filterByType {
                
                banks = banks.filter({$0.bankType == filter})
            }
            
            if let filter = filterByName, filter != "" {
                
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
        
        static func reduceCountry(_ model: Model) -> [ItemsListViewModel.Item] {
            
            let countryData = model.countriesList.value.filter({$0.paymentSystemIdList.contains("DIRECT")})
            var country = [ItemsListViewModel.Item]()
            
            country = countryData.map({ItemsListViewModel.Item(title: $0.name, image: $0.svgImage?.image, bankType: nil, action: {})})
            country = country.sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
            country = country.sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
            
            return country
        }
    }
    
    class CollapsableViewModel: ObservableObject, Hashable {
        
        let id = UUID()
        @Published var header: HeaderViewModel
        @Published var isCollapsed: Bool
        @Published var mode: Mode
        @Published var searchBar: SearchBarComponent.ViewModel = .init(clearButton: nil, cancelButton: .init(type: .title("Отмена"), action: {}), placeHolder: .banks, icon: .ic24Search, textColor: .mainColorsGrayLightest)
        @Published var items: ItemsListViewModel
        @Published var options: OptionSelectorView.ViewModel?
        
        internal init(header: HeaderViewModel, isCollapsed: Bool, mode: Mode, items: ContactsViewModel.ItemsListViewModel, options: OptionSelectorView.ViewModel? = nil) {
            self.header = header
            self.isCollapsed = isCollapsed
            self.mode = mode
            self.items = items
            self.options = options
        }
        
        convenience init(_ model: Model, kind: Kind) {
            
            let header: HeaderViewModel = .init(type: kind)
            let items: ItemsListViewModel = .init(model, type: kind)
            
            if kind != .country {
                
                let options: OptionSelectorView.ViewModel = Self.createOptionViewModel()
                self.init(header: header, isCollapsed: false, mode: .normal, items: items, options: options)
                
                self.header.searchButton?.action = {
                    
                    withAnimation {
                        
                        self.mode = self.mode == .normal ? .search : .normal
                    }
                }
                
                self.header.toggleButton.action = {
                    
                    withAnimation {
                        
                        self.isCollapsed.toggle()
                        self.header.toggleButton.icon = self.isCollapsed ? .ic24ChevronDown : .ic24ChevronUp
                    }
                }
                
                self.searchBar.cancelButton.action = {
                    
                    self.mode = .normal
                }
                
            } else {
                
                self.init(header: header, isCollapsed: false, mode: .normal, items: items)
            }
        }
        
        class HeaderViewModel: ObservableObject {
            
            @Published var icon: Image
            let title: Title
            @Published var searchButton: ButtonViewModel?
            @Published var toggleButton: ButtonViewModel
            
            init(type: Kind) {
                
                switch type {
                case .banks:
                    
                    self.icon = .ic40SBP
                    self.title = .otherBank
                    self.toggleButton = .init(icon: .ic24ChevronUp, action: {})
                    self.searchButton = .init(icon: .ic24Search, action: {})
                    
                case .country:
                    
                    self.icon = .ic48Abroad
                    self.title = .abroad
                    self.toggleButton = .init(icon: .ic24ChevronUp, action: {})
                    self.searchButton = nil
                }
            }
        }
        
        enum Mode {
            
            case normal
            case search
        }
        
        enum Title: String {
            
            case otherBank = "В другой банк"
            case abroad = "Переводы за рубеж"
        }
        
        struct ButtonViewModel {
            
            var icon: Image
            var action: () -> Void
        }
        
        static func createOptionViewModel() -> OptionSelectorView.ViewModel {
            
            let options = BankType.allCases.map({Option(id: $0.name, name: $0.name)})
            guard let firstOption = options.first?.id else {
                let optionViewModel: OptionSelectorView.ViewModel = .init(options: options, selected: "", style: .template, mode: .action)
                return  optionViewModel }
            
            let optionViewModel: OptionSelectorView.ViewModel = .init(options: options, selected: firstOption, style: .template, mode: .action)
            return optionViewModel
        }
        
        static func == (lhs: ContactsViewModel.CollapsableViewModel, rhs: ContactsViewModel.CollapsableViewModel) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
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
    
    func reduce(model: Model, filter: String? = nil) -> ContactsListViewModel {
        
        guard let addressBookContact: [AddressBookContact] = try? model.contactsAgent.fetchContactsList() else {
            return .init(selfContact: nil, contacts: [])
        }
        
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
        
        contacts = adressBookSorted.map({ contact in
            
            let icon = self.model.bankClientInfo.value.contains(where: {$0.phone == contact.phone}) ? Image("foraContactImage") : nil
            
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
        
        contacts = contacts.sorted(by: { firstContact, secondContact in
            guard let firstFullName = firstContact.fullName, let secondFullName = secondContact.fullName else {
                return true
            }
            
            return firstFullName.localizedCaseInsensitiveCompare(secondFullName) == .orderedAscending
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

extension ContactsViewModel {
    
    enum Kind: Equatable {
        
        case banks(BankType)
        case country
    }
}

enum ContactsViewModelAction {
    
    struct SetupPhoneNumber: Action {
        
        let phone: String
    }
}

extension ContactsViewModel {
    
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .contactsSearch(.init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(placeHolder: .contacts), mode: .contacts(.init(.emptyMock, items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))]), .init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
}
