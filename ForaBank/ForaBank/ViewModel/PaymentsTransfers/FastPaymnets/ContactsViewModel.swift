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
        case contactsSearch(ContactsListViewModel)
        case banks(TopBanksSectionType?, [CollapsableSectionViewModel])
        case banksSearch([CollapsableSectionViewModel])
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
    
    func bindCategorySelector(_ sections: [CollapsableSectionViewModel]) {
        
        for section in sections {
            
            switch section {
            case let section as BanksSectionCollapsableViewModel:
                
                section.options.action
                    .receive(on: DispatchQueue.main)
                    .sink{[unowned self] action in
                        
                        switch action {
                        case let payload as OptionSelectorAction.OptionDidSelected:
                            
                            section.options.selected = payload.optionId
                            
                            if payload.optionId == "Иностранные" {
                                
                                let banksData = model.bankList.value.filter({$0.bankType == .direct})
                                
                                section.items = banksData
                                    .map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
                                    .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
                                    .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
                                
                                section.header.icon = .ic24Bank
                                
                            } else if payload.optionId == "Российские" {
                                
                                let banksData = model.bankList.value.filter({$0.bankType == .sfp})
                                section.items = banksData
                                    .map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
                                    .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
                                    .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
                                
                                section.header.icon = .ic24SBP
                                
                            } else {
                                
                                let banksData = model.bankList.value
                                section.items = banksData
                                    .map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
                                    .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
                                    .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
                                
                                section.header.icon = .ic24Bank
                            }
                            
                        default: break
                        }
                        
                    }.store(in: &bindings)
                
                section.$mode
                    .receive(on: DispatchQueue.main)
                    .sink{ [unowned self] mode in
                        switch mode {
                        case .search(let search):
                            
                            section.isCollapsed = true
                            
                            search.action
                                .receive(on: DispatchQueue.main)
                                .sink { action in
                                    
                                    switch action {
                                    case _ as SearchBarComponent.ViewModelAction.ChangeState:
                                        
                                        section.mode = .normal
                                        
                                    default: break
                                    }
                                    
                                }.store(in: &bindings)
                            
                            search.$text
                                .receive(on: DispatchQueue.main)
                                .sink { text in
                                    
                                    if text != "" {
                                        
                                        let filteredBanks = self.model.bankList.value.filter({ bank in
                                            if bank.memberNameRus.localizedStandardContains(text) {
                                                
                                                return true
                                            }
                                            return false
                                        })
                                        
                                        section.items = filteredBanks
                                            .map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
                                            .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
                                            .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
                                        
                                    } else {
                                        
                                        section.options.selected = section.options.selected
                                    }
                                    
                                }.store(in: &bindings)
                            
                            
                        default: break
                        }
                    }.store(in: &bindings)
                
            default: break
            }
        }
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ContactsViewModelAction.SetupPhoneNumber:
                    let phoneNumberKit = PhoneNumberFormater()
                    let phone = phoneNumberKit.format(payload.phone)
                    self.searchBar.text = phone
                    
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
                        
                        let banksData = model.bankList.value
                        let bankSection = BanksSectionCollapsableViewModel(bankData: banksData)
                        
                        let countiesData = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
                        let countriesSection = CountrySectionCollapsableViewModel(countriesList: countiesData)
                        
                        let collapsable: [CollapsableSectionViewModel] = [bankSection, countriesSection]
                        
                        let banks = reduce(model: model, banks: banks)
                        
                        if let banks = banks {
                            
                            self.mode = .banks(.banks(banks), collapsable)
                            bindCategorySelector(collapsable)
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
                        self.model.action.send(ModelAction.BankClient.Request(phone: self.searchBar.text))
                        self.searchBar.textColor = .mainColorsBlack
                        self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: self.searchBar.text))
                        
                        let banksData = model.bankList.value
                        let bankSection = BanksSectionCollapsableViewModel(bankData: banksData)
                        
                        let countiesData = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
                        let countriesSection = CountrySectionCollapsableViewModel(countriesList: countiesData)
                        
                        let collapsable: [CollapsableSectionViewModel] = [bankSection, countriesSection]
                        
                        self.mode = .banks(.placeHolder(.init(placeHolderViewModel: Array(repeating: LatestPaymentsViewComponent.ViewModel.PlaceholderViewModel.init(), count: 6))), collapsable)
                        bindCategorySelector(collapsable)
                    }
                }
                
            }.store(in: &bindings)
        
        searchBar.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as SearchBarComponent.ViewModelAction.ChangeState:
                    
                    if !searchBar.isValidation {
                        
                        withAnimation {
                            
                            let latestPaymentsFilterred = model.latestPayments.value.filter({$0.type == .phone})
                            let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                            
                            if searchBar.text == "" {
                                
                                let contacts = reduce(model: self.model)
                                self.mode = .contacts(.init(model, items: items), contacts)
                                
                            } else {
                                
                                let contacts = reduce(model: self.model, filter: searchBar.text)
                                self.mode = .contacts(.init(model, items: items), contacts)
                            }
                        }
                    }
                    
                default: break
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
        
        init(fullName: String?, image: IconImage?, phone: String, icon: Image?, action: @escaping () -> Void) {
            
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
        case placeHolder(PlaceHolderViewModel)
    }
    
    struct PlaceHolderViewModel {
        
        let placeHolderViewModel: [LatestPaymentsViewComponent.ViewModel.PlaceholderViewModel]
    }
    
    class TopBanksViewModel: Equatable {
        
        @Published var banks: [Bank]
        
        internal init(banks: [Bank]) {
            self.banks = banks
        }
        
        struct Bank: Hashable {
            
            let image: Image?
            let defaultBank: Bool
            let name: String?
            let bankName: String
            let action: () -> Void
            
            init(image: Image?, defaultBank: Bool, name: String?, bankName: String, action: @escaping () -> Void) {
                
                self.image = image
                self.name = name
                self.defaultBank = defaultBank
                self.bankName = bankName
                self.action = action
            }
            
            static func == (lhs: Bank, rhs: Bank) -> Bool {
                
                lhs.name == rhs.name
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(name)
            }
        }
        
        static func == (lhs: ContactsViewModel.TopBanksViewModel, rhs: ContactsViewModel.TopBanksViewModel) -> Bool {
            lhs.banks == rhs.banks
        }
    }
    
    class CollapsableSectionViewModel: ObservableObject, Hashable, Equatable {
        
        let id = UUID()
        @Published var header: HeaderViewModel
        @Published var isCollapsed: Bool
        @Published var items: [ItemViewModel]
        
        private var bindings = Set<AnyCancellable>()
        
        init(header: HeaderViewModel, isCollapsed: Bool = false, items: [ItemViewModel]) {
            
            self.isCollapsed = isCollapsed
            self.header = header
            self.items = items
            
            bind()
        }
        
        func bind() {
            
            header.$isCollapsed
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { isCollapsed in
                    
                    self.isCollapsed.toggle()
                    
                }.store(in: &bindings)
        }
        
        class HeaderViewModel: ObservableObject {
            
            @Published var icon: Image
            var title: String
            @Published var isCollapsed: Bool
            @Published var searchButton: ButtonViewModel?
            @Published var toggleButton: ButtonViewModel
            
            init(icon: Image, isCollapsed: Bool = false, title: String, searchButton: ButtonViewModel? = nil, toggleButton: ButtonViewModel) {
                
                self.icon = icon
                self.isCollapsed = isCollapsed
                self.title = title
                self.searchButton = searchButton
                self.toggleButton = toggleButton
            }
            
            convenience init(kind: Kind) {
                
                switch kind {
                    
                case .banks:
                    let icon: Image = .ic24SBP
                    let title = "В другой банк"
                    let toggleButton = ButtonViewModel(icon: .ic24ChevronUp, action: {})
                    let searchButton = ButtonViewModel(icon: .ic24Search, action: {})
                    
                    self.init(icon: icon, title: title, searchButton: searchButton, toggleButton: toggleButton)
                    
                case .country:
                    let icon: Image = .ic24Abroad
                    let title = "Переводы за рубеж"
                    let button = ButtonViewModel(icon: .ic24ChevronUp, action: {})
                    
                    self.init(icon: icon, title: title, toggleButton: button)
                }
            }
            
            struct ButtonViewModel {
                
                var icon: Image
                var action: () -> Void
            }
        }
        
        class ItemViewModel: Hashable {
            
            let title: String
            let image: Image?
            let bankType: BankType?
            let action: () -> Void
            
            init(title: String, image: Image?, bankType: BankType?, action: @escaping () -> Void) {
                
                self.title = title
                self.image = image
                self.bankType = bankType
                self.action = action
            }
            
            static func == (lhs: ItemViewModel, rhs: ItemViewModel) -> Bool {
                lhs.title == rhs.title
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(title)
            }
        }
        
        enum Kind {
            case banks, country
        }
    }
    
    class BanksSectionCollapsableViewModel: CollapsableSectionViewModel {
        
        @Published var mode: Mode
        @Published var options: OptionSelectorView.ViewModel
        
        init(header: CollapsableSectionViewModel.HeaderViewModel, items: [CollapsableSectionViewModel.ItemViewModel], mode: Mode, options: OptionSelectorView.ViewModel) {
            
            self.mode = mode
            self.options = options
            super.init(header: header, items: items)
        }
        
        convenience init(bankData: [BankData]) {
            let items = Self.reduceBanks(banksData: bankData)
            let options = Self.createOptionViewModel()
            
            self.init(header: .init(kind: .banks), items: items, mode: .normal, options: options)
        }
        
        enum Mode {
            
            case normal
            case search(SearchBarComponent.ViewModel)
        }
        
        static func createOptionViewModel() -> OptionSelectorView.ViewModel {
            
            let options = BankType.allCases.map { bankType in
                
                if bankType.name == "Неизвестно" {
                    
                    return Option(id: "all", name: "Все")
                } else {
                    
                    return Option(id: bankType.name, name: bankType.name)
                }
            }
            guard let firstOption = options.first?.id else {
                let optionViewModel: OptionSelectorView.ViewModel = .init(options: options, selected: "", style: .template, mode: .action)
                return  optionViewModel }
            
            let optionViewModel: OptionSelectorView.ViewModel = .init(options: options, selected: firstOption, style: .template, mode: .action)
            return optionViewModel
        }
        
        static func reduceBanks(banksData: [BankData], filterByType: BankType? = nil, filterByName: String? = nil) -> [CollapsableSectionViewModel.ItemViewModel] {
            
            var banks = [CollapsableSectionViewModel.ItemViewModel]()
            
            banks = banksData.map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
            banks = banks.sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
            banks = banks.sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
            
            if let filter = filterByType {
                
                banks = banks.filter({$0.bankType == filter})
            }
            
            if let filter = filterByName, filter != "" {
                banks = banks.filter({ bank in
                    if bank.title.localizedStandardContains(filter) {
                        
                        return true
                    }
                    return false
                })
            }
            
            return banks
        }
    }
    
    class CountrySectionCollapsableViewModel: CollapsableSectionViewModel {
        
        override init(header: CollapsableSectionViewModel.HeaderViewModel, isCollapsed: Bool = false, items: [CollapsableSectionViewModel.ItemViewModel]) {
            
            super.init(header: header, items: items)
        }
        
        convenience init(countriesList: [CountryData]) {
            
            let items = Self.reduceCounry(countriesList: countriesList)
            self.init(header: .init(kind: .country), items: items)
        }
        
        static func reduceCounry(countriesList: [CountryData]) -> [CollapsableSectionViewModel.ItemViewModel] {
            
            var country = [CollapsableSectionViewModel.ItemViewModel]()
            
            country = countriesList.map({CollapsableSectionViewModel.ItemViewModel(title: $0.name, image: $0.svgImage?.image, bankType: nil, action: {})})
            country = country.sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
            country = country.sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
            
            return country
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
            
            let icon = self.model.bankClientInfo.value.contains([BankClientInfo(phone: contact.phone)]) ? Image("foraContactImage") : nil
            
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

extension ContactsViewModel.CollapsableSectionViewModel {
    
    static func == (lhs: ContactsViewModel.CollapsableSectionViewModel, rhs: ContactsViewModel.CollapsableSectionViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
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
    
    static let sampleBanks = BanksSectionCollapsableViewModel(header: .init(kind: .banks), items: [.sampleItem], mode: .normal, options: .sample)
    
    static let sampleHeader = ContactsViewModel.CollapsableSectionViewModel.HeaderViewModel(kind: .country)
}

extension ContactsViewModel.CollapsableSectionViewModel.ItemViewModel {
    
    static let sampleItem = ContactsViewModel.CollapsableSectionViewModel.ItemViewModel(title: "Банк", image: .ic24Bank, bankType: .sfp, action: {})
}

extension ContactsViewModel.CollapsableSectionViewModel {
    
    static let sampleHeader = ContactsViewModel.CollapsableSectionViewModel.HeaderViewModel(kind: .country)
}

extension ContactsViewModel.CollapsableSectionViewModel.HeaderViewModel {
    
    static let sampleHeader = ContactsViewModel.CollapsableSectionViewModel.HeaderViewModel(kind: .banks)
}
