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
            case let section as BanksCollapsableViewModel:
                
                section.options?.action
                    .receive(on: DispatchQueue.main)
                    .sink{[unowned self] action in
                        
                        switch action {
                        case let payload as OptionSelectorAction.OptionDidSelected:
                            
                            section.options?.selected = payload.optionId
                            
                            if payload.optionId != "Российские" {
                                
//                                section.items = .init(self.model, type: .banks(.direct))
                                section.header.icon = .ic24Bank
                                
                            } else {
                                
//                                section.items = .init(self.model, type: .banks(.sfp))
                                section.header.icon = .ic40SBP
                            }
                            
                        default: break
                        }
                        
                    }.store(in: &bindings)
                
            default: break
            }
            
            //            section.searchBar.$text
            //                .receive(on: DispatchQueue.main)
            //                .sink{ [unowned self] text in
            //
            //                    section.items = .init(self.model, type: .banks(.sfp), filterText: text)
            //
            //                }.store(in: &bindings)
            
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
                        
                        let collapsable: [CollapsableSectionViewModel] = [.init(kind: .banks), .init(kind: .country)]
                        
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
    
    class CollapsableSectionViewModel: ObservableObject, Hashable {
        
        @Published var header: HeaderViewModel
        var isCollapsed: Bool
        @Published var items: [ItemViewModel]
        
        internal init(header: HeaderViewModel, isCollapsed: Bool, items: [ItemViewModel]) {
            
            self.header = header
            self.isCollapsed = isCollapsed
            self.items = items
        }
        
        convenience init(kind: Kind) {
            
            switch kind {
                
            case .banks:
                let header = HeaderViewModel(icon: .ic40SBP, title: "В другой банк", toggleButton: .init(icon: .ic24ChevronUp, action: {}))
                let items = [ItemViewModel]()
                
                self.init(header: header, isCollapsed: false, items: items)
                
            case .country:
                let header = HeaderViewModel(icon: .ic48Abroad, title: "За рубеж", toggleButton: .init(icon: .ic24ChevronUp, action: {}))
                let items = [ItemViewModel]()
                
                self.init(header: header, isCollapsed: false, items: items)
            }
        }
        
        enum Kind {
            case banks, country
        }
        
        class HeaderViewModel {
            
            @Published var icon: Image
            let title: String
            @Published var toggleButton: ButtonViewModel
            
            internal init(icon: Image, title: String, toggleButton: ButtonViewModel) {
                
                self.icon = icon
                self.title = title
                self.toggleButton = toggleButton
            }
        }
        
        struct ButtonViewModel {
            
            var icon: Image
            var action: () -> Void
        }
        
        class ItemViewModel: Identifiable, Hashable {
            
            let id = UUID()
            let title: String
            let image: Image?
            let bankType: BankType?
            let action: () -> Void
            let kind: Kind
            
            internal init(title: String, image: Image?, bankType: BankType?, kind: Kind, action: @escaping () -> Void) {
                
                self.title = title
                self.image = image
                self.bankType = bankType
                self.action = action
                self.kind = kind
            }
            
            static func == (lhs: ItemViewModel, rhs: ItemViewModel) -> Bool {
                lhs.id == rhs.id && lhs.title == rhs.title
            }
            
            func hash(into hasher: inout Hasher) {
                
                hasher.combine(id)
                hasher.combine(title)
            }
        }
    }
    
    class BanksCollapsableViewModel: CollapsableSectionViewModel {
        
        @Published var mode: Mode
        @Published var options: OptionSelectorView.ViewModel?
        
        internal init(header: CollapsableSectionViewModel.HeaderViewModel, isCollapsed: Bool, items: [CollapsableSectionViewModel.ItemViewModel], mode: Mode, options: OptionSelectorView.ViewModel? = nil) {
            
            self.mode = mode
            self.options = options
            super.init(header: header, isCollapsed: isCollapsed, items: items)
        }
        
        enum Mode {
            
            case normal
            case search(SearchBarComponent.ViewModel)
        }
    }
    
    class CountryCollapsableViewModel: CollapsableSectionViewModel {}
    
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

extension ContactsViewModel.CollapsableSectionViewModel {
    
    static func == (lhs: ContactsViewModel.CollapsableSectionViewModel, rhs: ContactsViewModel.CollapsableSectionViewModel) -> Bool {
        lhs.isCollapsed == rhs.isCollapsed
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(isCollapsed)
        hasher.combine(header.title.hashValue)
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
