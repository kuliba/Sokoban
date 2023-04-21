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

    @Published var searchBar: SearchBarView.ViewModel
    @Published var visible: [ContactsSectionViewModel]
    @Published var mode: Mode
    
    private var sections: [ContactsSectionViewModel]
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var title: String {
        
        switch mode {
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

    init(_ model: Model, searchBar: SearchBarView.ViewModel, visible: [ContactsSectionViewModel], sections: [ContactsSectionViewModel], mode: Mode) {
        
        self.model = model
        self.searchBar = searchBar
        self.visible = visible
        self.sections = sections
        self.mode = mode

        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    convenience init(_ model: Model, mode: Mode) {
 
        self.init(model, searchBar: Self.searchBar(for: mode), visible: [], sections: [], mode: mode)
        
        sections = sections(for: mode, model: model)

        bind()
        bind(sections: sections)
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    private func bind() {
        
        $mode
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] mode in
                
                withAnimation {
                    
                    visible = visible(sections: sections, mode: mode)
                }

            }.store(in: &bindings)
        
        searchBar.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                switch mode {
                case let .fastPayments(phase):
                    
                    contactsSection?.filter.value = text
                    banksPrefferdSection?.phone.value = text
                    banksSection?.phone.value = text
                    
                    switch phase {
                    case .contacts:

                        if let phone = searchBar.phone {
                            
                            feedbackGenerator.notificationOccurred(.success)
                            self.searchBar.action.send(SearchBarViewModelAction.Idle())
                            mode = .fastPayments(.banksAndCountries(phone: phone))

                            model.action.send(ModelAction.BankClient.Request(phone: phone.digits))
                            model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: phone))

                        } else {
 
                            withAnimation {
                                
                                if text != nil {
                 
                                    // hide latest payments
                                    visible = visible.filter({ $0.type != .latestPayments })

                                } else {
                                    
                                    // show latest payments
                                    visible = visible(sections: sections, mode: mode)
                                }
                            }
                        }
                        
                    case .banksAndCountries:
                        
                        if let phone = searchBar.phone {
                            
                            mode = .fastPayments(.banksAndCountries(phone: phone))
                            
                        } else {
                            
                            mode = .fastPayments(.contacts)
                        }
                    }
                    
                case .abroad:
                    countriesSection?.filter.value = text
                    
                case let .select(select):
                    switch select {
                    case .contacts:
                        contactsSection?.filter.value = text
                        
                    case .banks:
                        banksSection?.filter.value = text
                   
                    case .banksFullInfo:
                        banksSection?.filter.value = text
                        
                    case .countries:
                        countriesSection?.filter.value = text
                    }
                }

            }.store(in: &bindings)
    }
    
    func bind(sections: [ContactsSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ContactsSectionViewModelAction.LatestPayments.ItemDidTapped:
                        self.action.send(ContactsViewModelAction.PaymentRequested(source: .latestPayment(payload.latestPaymentId)))
                        
                    case let payload as ContactsSectionViewModelAction.Contacts.ItemDidTapped:
                        switch mode {
                        case .fastPayments:
                            let formattedPhone = searchBar.textField.phoneNumberFormatter.partialFormatter("+\(payload.phone)")
                            self.searchBar.textField.setText(to: formattedPhone)
                        
                        case .abroad:
                            break
                            
                        case .select:
                            let formattedPhone = searchBar.textField.phoneNumberFormatter.partialFormatter("+\(payload.phone)")
                            self.action.send(ContactsViewModelAction.ContactPhoneSelected(phone: formattedPhone))
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

                                    self.action.send(ContactsViewModelAction.PaymentRequested(source: .direct(phone: self.searchBar.phone, countryId: countryId)))

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
                        visible = visible(sections: sections, mode: mode)
                    
                    case let payload as ContactsViewModelAction.ContactsDidScroll:
                        
                        if payload.isVisible {
                            
                            withAnimation(.linear(duration: 0.5)) {
                            
                                visible = visible(sections: sections, mode: mode)
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

//MARK: - Types

extension ContactsViewModel {
    
    enum Mode {
        
        case fastPayments(Phase)
        case select(Select)
        case abroad
        
        enum Phase {
            
            case contacts
            case banksAndCountries(phone: String)
        }
        
        enum Select {
            
            case contacts
            case banks
            case banksFullInfo
            case countries
        }
        
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
    }
}

//MARK: - Reducers

extension ContactsViewModel {
    
    static func searchBar(for mode: Mode) -> SearchBarView.ViewModel {
        
        switch mode {
        case .fastPayments:
            return .init(textFieldPhoneNumberView: .init(placeHolder: .contacts, style: .payments))
        
        case .abroad:
            return .init(textFieldPhoneNumberView: .init(style: .abroad, placeHolder: .countries), state: .idle, icon: .ic24Search)

        case let .select(select):
            switch select {
            case .contacts:
                return .init(textFieldPhoneNumberView: .init(placeHolder: .contacts, style: .payments))
                
            case .banks:
                return .init(textFieldPhoneNumberView: .init(.banks))
            
            case .banksFullInfo:
                return .init(textFieldPhoneNumberView: .init(style: .banks, placeHolder: .banks))
                
            case .countries:
                return .init(textFieldPhoneNumberView: .init(.countries))
            }
        }
    }
    
    func sections(for mode: Mode, model: Model) -> [ContactsSectionViewModel] {
        
        var result = [ContactsSectionViewModel]()
        
        switch mode {
        case .fastPayments:
            result.append(ContactsLatestPaymentsSectionViewModel(model: model, including: [.phone]))
            result.append(ContactsListSectionViewModel(model, mode: .fastPayment))
            result.append(ContactsBanksPrefferedSectionViewModel(model, phone: nil))
            result.append(ContactsBanksSectionViewModel(model, mode: .fastPayment, phone: nil, bankDictionary: .banks))
            result.append(ContactsCountriesSectionViewModel(model, mode: .fastPayment))

        case .abroad:
            result.append(ContactsLatestPaymentsSectionViewModel(model: model, including: [.outside]))
            result.append(ContactsCountriesSectionViewModel(model, mode: .select))

        case let .select(select):
            switch select {
            case .contacts:
                result.append(ContactsListSectionViewModel(model, mode: .select))
                
            case .banks:
                result.append(ContactsBanksSectionViewModel(model, mode: .select, phone: nil, bankDictionary: .banks))
                
            case .banksFullInfo:
                result.append(ContactsBanksSectionViewModel(model, mode: .select, phone: nil, bankDictionary: .banksFullInfo))

            case .countries:
                result.append(ContactsCountriesSectionViewModel(model, mode: .select))
            }
        }
        
        return result
    }
    
    func visible(sections: [ContactsSectionViewModel], mode: Mode) -> [ContactsSectionViewModel] {
        
        sections.filter({ mode.visibleSectionsTypes.contains($0.type) })
    }
}

//MARK: - Helpers

extension ContactsViewModel {
    
    private var contactsSection: ContactsListSectionViewModel? {
        
        guard let section = sections.compactMap({ $0 as? ContactsListSectionViewModel }).first else {
            return nil
        }
        return section
    }
    
    private var banksSection: ContactsBanksSectionViewModel? {
        
        guard let section = sections.compactMap({ $0 as? ContactsBanksSectionViewModel }).first else {
            return nil
        }
        return section
    }
    
    private var countriesSection: ContactsCountriesSectionViewModel? {
        
        guard let section = sections.compactMap({ $0 as? ContactsCountriesSectionViewModel }).first else {
            return nil
        }
        return section
    }
    
    private var banksPrefferdSection: ContactsBanksPrefferedSectionViewModel? {
        
        guard let section = sections.compactMap({ $0 as? ContactsBanksPrefferedSectionViewModel }).first else {
            return nil
        }
        return section
    }
    
    func handleBankDidTapped(bankId: BankData.ID) {
        
        guard let phone = searchBar.phone,
              let bank = model.bankList.value.first(where: { $0.id == bankId }) else {
            
            return
        }
        
        switch bank.bankType {
        case .sfp:
            #if DEBUG
            self.action.send(ContactsViewModelAction.PaymentRequested(source: .mock(model.paymentsMockSFP())))
            #else
            self.action.send(ContactsViewModelAction.PaymentRequested(source: .sfp(phone: phone, bankId: bank.id)))
            #endif
            
        case .direct:
            guard let country = self.model.countriesList.value.first(where: { $0.id == bank.bankCountry}) else {
                return
            }
            self.action.send(ContactsViewModelAction.PaymentRequested(source: .direct(phone: phone, countryId: country.id)))
            
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

