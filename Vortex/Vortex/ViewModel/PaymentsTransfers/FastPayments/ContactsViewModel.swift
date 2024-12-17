//
//  ContactsViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.09.2022.
//

import Foundation
import SwiftUI
import Combine
import TextFieldComponent

class ContactsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()

    @Published private(set) var visible: [ContactsSectionViewModel]
    @Published private(set) var mode: Mode
    
    let searchFieldModel: RegularFieldViewModel

    private var sections: [ContactsSectionViewModel]
    
    private let makeRequest: (String) -> Void
    private let bankFromID: (BankData.ID) -> BankData?
    private let countryForBank: (BankData) -> CountryData?
    private let validator: any Validator
    private let scheduler: AnySchedulerOfDispatchQueue
    
    private var bindings = Set<AnyCancellable>()
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    init(
        searchFieldModel: RegularFieldViewModel,
        visible: [ContactsSectionViewModel],
        sections: [ContactsSectionViewModel],
        mode: ContactsViewModel.Mode,
        makeRequest: @escaping (String) -> Void,
        bankFromID: @escaping (BankData.ID) -> BankData?,
        countryForBank: @escaping (BankData) -> CountryData?,
        validator: any Validator,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.searchFieldModel = searchFieldModel
        self.visible = visible
        self.sections = sections
        self.mode = mode
        self.makeRequest = makeRequest
        self.bankFromID = bankFromID
        self.countryForBank = countryForBank
        self.validator = validator
        self.scheduler = scheduler
        
        bind()
        bind(sections: sections)
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    func bind() {
        
        $mode
            .receive(on: scheduler)
            .sink { [unowned self] mode in
                
                withAnimation {
                    
                    visible = sections.visible(forMode: mode)
                }

            }.store(in: &bindings)
        
        searchFieldModel.$state
            .map(\.text)
            .receive(on: scheduler)
            .sink { [unowned self] text in
                
                switch mode {
                case let .fastPayments(phase):
                    
                    sections.contactsSection?.filter.value = text
                    sections.banksPrefferdSection?.phone.value = text
                    sections.banksSection?.phone.value = text
                    
                    switch phase {
                    case .contacts:

                        if let validatedPhone {
                            
                            feedbackGenerator.notificationOccurred(.success)
                            finishEditing()
                            mode = .fastPayments(.banksAndCountries(phone: validatedPhone))
                            makeRequest(validatedPhone)

                        } else {
 
                            withAnimation {
                                
                                visible = text != nil
                                // hide latest payments
                                ? visible.withoutLastPayments
                                // show latest payments
                                : sections.visible(forMode: mode)
                            }
                        }
                        
                    case .banksAndCountries:
                        
                        if let validatedPhone {
                            
                            mode = .fastPayments(.banksAndCountries(phone: validatedPhone))
                            
                        } else {
                            
                            mode = .fastPayments(.contacts)
                        }
                    }
                    
                case .abroad:
                    sections.countriesSection?.filter.value = text
                    
                case let .select(select):
                    switch select {
                    case .contacts:
                        sections.contactsSection?.filter.value = text
                        
                    case .banks:
                        sections.banksSection?.filter.value = text
                   
                    case .banksFullInfo:
                        sections.banksSection?.filter.value = text
                        
                    case .countries:
                        sections.countriesSection?.filter.value = text
                    }
                }

            }.store(in: &bindings)
    }
    
    func bind(sections: [ContactsSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: scheduler)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ContactsSectionViewModelAction.LatestPayments.ItemDidTapped:
                        self.action.send(ContactsViewModelAction.PaymentRequested(source: .latestPayment(payload.latestPaymentId)))
                        
                    case let payload as ContactsSectionViewModelAction.Contacts.ItemDidTapped:
                        switch mode {
                        case .fastPayments:
                            self.setText(to: payload.phone)
                        
                        case .abroad:
                            break
                            
                        case .select:
                            self.action.send(ContactsViewModelAction.ContactPhoneSelected(phone: payload.phone))
                        }
                        
                    case let payload as ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped:
                        handleBankDidTapped(bankId: payload.bankId)
                        
                    case let payload as ContactsSectionViewModelAction.Banks.ItemDidTapped:
                        switch mode {
                        case .fastPayments:
                            handleBankDidTapped(bankId: payload.bankId)
                        
                        case .abroad:
                            break
                            
                        case .select:
                            self.action.send(ContactsViewModelAction.BankSelected(bankId: payload.bankId))
                        }
   
                    case let payload as ContactsSectionViewModelAction.Countries.ItemDidTapped:
                        
                        switch mode {
                        case let .fastPayments(phase):
                            switch phase {
                            case .banksAndCountries(phone: _):
                                
                                if case let .direct(phone: _, countryId: countryId, serviceData: _) = payload.source {

                                    self.action.send(ContactsViewModelAction.PaymentRequested(source: .direct(phone: self.validatedPhone, countryId: countryId)))

                                } else {
                                    
                                    self.action.send(ContactsViewModelAction.PaymentRequested(source: payload.source))
                                }
                                
                            default:
                                break
                            }
                        case .abroad:
                            self.action.send(ContactsViewModelAction.PaymentRequested(source: payload.source))

                        case .select:
                            switch payload.source {
                            case let .direct(phone: _, countryId: countryId, serviceData: _):
                                self.action.send(ContactsViewModelAction.CountrySelected(countryId: countryId))
                                
                            default:
                                self.action.send(ContactsViewModelAction.PaymentRequested(source: payload.source))
                            }
                        }
                        
                    case _ as ContactsSectionViewModelAction.Collapsable.HideCountries:
                        visible = visible.filter({ $0.type != .countries })
                        
                    case _ as ContactsSectionViewModelAction.Collapsable.ResetSections:
                        visible = sections.visible(forMode: mode)
                    
                    case let payload as ContactsViewModelAction.ContactsDidScroll:
                        
                        if payload.isVisible {
                            
                            withAnimation(.linear(duration: 0.5)) {
                            
                                visible = sections.visible(forMode: mode)
                            }
                        } else {
                            
                            withAnimation(.linear(duration: 0.5)) {
                                
                                visible = visible.filter({ $0.type != .latestPayments})
                            }
                        }
                    
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - interaction

extension ContactsViewModel {
    
    func cancelSearch() {
        
        setText(to: nil)
    }
    
    func setMode(to mode: Mode) {
        
        self.mode = mode
    }
    
    private func setText(to text: String?) {
        
        self.searchFieldModel.setText(to: text)
    }
    
    private func finishEditing() {
        
        searchFieldModel.finishEditing()
    }
    
    var title: String { mode.title }
    
    var validatedPhone: String? {
        
#if DEBUG
        if searchFieldModel.text == "+7 0115110217" { return searchFieldModel.text }
#endif
        guard let text = searchFieldModel.text,
              validator.isValid(text)
        else { return nil }
        
        return text
    }
}

//MARK: - Types

extension ContactsViewModel {
    
    enum Mode: Equatable {
        
        case fastPayments(Phase)
        case select(Select)
        case abroad
        
        enum Phase: Equatable {
            
            case contacts
            case banksAndCountries(phone: String)
        }
        
        enum Select: Equatable {
            
            case contacts
            case banks(phone: String?)
            case banksFullInfo
            case countries
        }
    }
}

extension ContactsViewModel.Mode {
    
    var visibleSectionsTypes: [ContactsSectionViewModel.Kind] {
        
        switch self {
        case let .fastPayments(phase):
            switch phase {
            case .contacts:
                return [.latestPayments, .contacts]
                
            case .banksAndCountries:
                return [.banksPreferred, .banks, .countries]
            }
            
        case .abroad:
            return [.latestPayments, .countries]
            
        case let .select(select):
            switch select {
            case .contacts: return [.contacts]
            case .banks: return [.banks]
            case .banksFullInfo: return [.banks]
            case .countries: return [.countries]
            }
        }
    }
    
    var title: String {
        
        switch self {
        case .fastPayments: return "Выберите контакт"
        case .abroad: return "В какую страну?"
        case let .select(select):
            switch select {
            case .contacts: return "Выберите контакт"
            case .banks: return "Выберите банк"
            case .banksFullInfo: return "Выберите банк"
            case .countries: return "Выберите страну"
            }
        }
    }
}

extension Model {

    // MARK: - Factory
    
    /// Factory method to create `ContactsViewModel` using `model`.
    func makeContactsViewModel(
        forMode mode: ContactsViewModel.Mode,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> ContactsViewModel {
        
        let model = self
        
        let makeRequest: (String) -> Void = { [weak model] phone in
            
            model?.action.send(ModelAction.BankClient.Request(phone: phone.digits))
            model?.action.send(ModelAction.LatestPayments.BanksList.Request(
                prePayment: true,
                phone: phone
            ))
        }
        let bankFromID: (BankData.ID) -> BankData? = { [weak model] bankId in
            
            model?.bankList.value.first(where: { $0.id == bankId })
        }
        let countryForBank: (BankData) -> CountryData? = { [weak model] bank in
            
            model?.countriesList.value.first(where: { $0.id == bank.bankCountry })
        }
                
        let searchFieldModel = SearchFactory.makeSearchFieldModel(
            for: mode,
            scheduler: scheduler
        )
        let sections = model.sections(for: mode)
        let validator = PhoneValidator()
        
        return .init(searchFieldModel: searchFieldModel, visible: [], sections: sections, mode: mode, makeRequest: makeRequest, bankFromID: bankFromID, countryForBank: countryForBank, validator: validator, scheduler: scheduler)
    }
    
    /// - Note: `internal` is for testing
    internal func sections(
        for mode: ContactsViewModel.Mode
    ) -> [ContactsSectionViewModel] {
        
        let model = self
        
        switch mode {
        case .fastPayments:
            return [
                ContactsLatestPaymentsSectionViewModel(model: model, including: [.phone]),
                ContactsListSectionViewModel(model, mode: .fastPayment),
                ContactsBanksPrefferedSectionViewModel(model, phone: nil),
                ContactsBanksSectionViewModel(model, mode: .fastPayment, phone: nil, bankDictionary: .banks, searchTextFieldFactory: { .bank() }),
                ContactsCountriesSectionViewModel(model, mode: .fastPayment)
            ]
            
        case .abroad:
            return [
                ContactsLatestPaymentsSectionViewModel(model: model, including: [.outside]),
                ContactsCountriesSectionViewModel(model, mode: .select)
            ]
            
        case let .select(select):
            switch select {
            case .contacts:
                return [
                    ContactsListSectionViewModel(model, mode: .select)
                ]
                
            case let .banks(phone):
                return [
                    ContactsBanksSectionViewModel(
                        model,
                        mode: .select,
                        phone: phone,
                        bankDictionary: .banks,
                        searchTextFieldFactory: { .bank() }
                    )
                ]
                
            case .banksFullInfo:
                return [
                    ContactsBanksSectionViewModel(
                        model,
                        mode: .select,
                        phone: nil,
                        bankDictionary: .banksFullInfo,
                        searchTextFieldFactory: { .bank() }
                    )
                ]
                
            case .countries:
                return [
                    ContactsCountriesSectionViewModel(model, mode: .select)
                ]
            }
        }
    }
}

// MARK: - Helpers

extension Array where Element == ContactsSectionViewModel {
    
    var latestPayments: ContactsLatestPaymentsSectionViewModel? {
        
        compactMap({ $0 as? ContactsLatestPaymentsSectionViewModel }).first
    }
    
    var contactsSection: ContactsListSectionViewModel? {
        
        compactMap({ $0 as? ContactsListSectionViewModel }).first
    }
    
    var banksSection: ContactsBanksSectionViewModel? {
        
        compactMap({ $0 as? ContactsBanksSectionViewModel }).first
    }
    
    var countriesSection: ContactsCountriesSectionViewModel? {
        
        compactMap({ $0 as? ContactsCountriesSectionViewModel }).first
    }
    
    var banksPrefferdSection: ContactsBanksPrefferedSectionViewModel? {
        
        compactMap({ $0 as? ContactsBanksPrefferedSectionViewModel }).first
    }
    
    var withoutLastPayments: Self {
        
        filter { $0.type != .latestPayments }
    }
    
    func visible(forMode mode: ContactsViewModel.Mode) -> Self {
        
        filter { mode.visibleSectionsTypes.contains($0.type) }
    }
}

extension RegularFieldViewModel {
    
    static func bank() -> RegularFieldViewModel {
        
        TextFieldFactory.makeTextField(
            text: nil,
            placeholderText: "Введите название банка",
            keyboardType: .default,
            limit: nil
        )
    }
}

extension ContactsViewModel {
    
    func handleBankDidTapped(bankId: BankData.ID) {
        
        guard let validatedPhone,
              let bank = bankFromID(bankId)
        else { return }
        
        switch bank.bankType {
        case .sfp:
            #if DEBUG
            let source: Payments.Operation.Source = .mock(Model.paymentsMockSFP())
            #else
            let source: Payments.Operation.Source = .sfp(phone: validatedPhone, bankId: bank.id, amount: nil, productId: nil)
            #endif
            self.action.send(ContactsViewModelAction.PaymentRequested(source: source))
            
        case .direct:
            guard let country = countryForBank(bank) else {
                return
            }
            self.action.send(ContactsViewModelAction.PaymentRequested(source: .direct(phone: validatedPhone, countryId: country.id)))
            
        default:
            return
        }
    }
}

//MARK: - Action

enum ContactsViewModelAction {

    struct PaymentRequested: Action {
        
        let source: Payments.Operation.Source
    }
    
    struct ContactPhoneSelected: Action {
        
        let phone: String
    }
    
    struct BankSelected: Action {
        
        let bankId: BankData.ID
    }
    
    struct CountrySelected: Action {
        
        let countryId: CountryData.ID
    }
    
    struct ContactsDidScroll: Action {
        
        let isVisible: Bool
    }
}

//MARK: - Preview Content

extension ContactsViewModel {
    
    static let sampleFastContacts = ContactsViewModel.preview(
        visible: [
            ContactsLatestPaymentsSectionViewModel.sample,
            ContactsListSectionViewModel.sample
        ])
    
    static let sampleFastBanks = ContactsViewModel.preview(
        visible: [
            ContactsBanksPrefferedSectionViewModel.sample,
            ContactsBanksSectionViewModel.sample,
            ContactsCountriesSectionViewModel.sample
        ])
    
    static func preview(
        searchFieldModel: RegularFieldViewModel = SearchFactory.makeSearchContactsField(),
        visible: [ContactsSectionViewModel],
        sections: [ContactsSectionViewModel] = [],
        mode: Mode = .fastPayments(.contacts)
    ) -> ContactsViewModel {
        
        .init(
            searchFieldModel: searchFieldModel,
            visible: visible,
            sections: sections,
            mode: mode,
            makeRequest: { _ in },
            bankFromID: { _ in nil },
            countryForBank: { _ in nil },
            validator: Validate.always
        )
    }
}

// MARK: - DSL

extension ContactsViewModel {
    
    var firstSection: ContactsSectionViewModel? {
        
        sections.first
    }
    
    var contactsSection: ContactsListSectionViewModel? {
        
        sections.contactsSection
    }
    
    var banksSection: ContactsBanksSectionViewModel? {
        
        sections.banksSection
    }
    
    var countriesSection: ContactsCountriesSectionViewModel? {
        
        sections.countriesSection
    }
    
    var banksPrefferdSection: ContactsBanksPrefferedSectionViewModel? {
        
        sections.banksPrefferdSection
    }
}
