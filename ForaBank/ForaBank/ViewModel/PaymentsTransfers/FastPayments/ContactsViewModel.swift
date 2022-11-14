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
        case .sfp: return "Выберите контакт"
        case let .select(select, _):
            switch select {
            case .contacts: return "Выберите контакт"
            case .banks: return "Выберите банк"
            case .counties: return "Выберите страну"
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
 
        self.init(model, searchBar: .init(textFieldPhoneNumberView: .init(.contacts)), visible: [], sections: [], mode: mode)
        
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
                case let .sfp(phase):
                    switch phase {
                    case .contacts:
                        if let phone = searchBar.phone {
                            
                            self.feedbackGenerator.notificationOccurred(.success)
                            self.searchBar.action.send(SearchBarViewModelAction.Idle())
                            
                            self.model.action.send(ModelAction.BankClient.Request(phone: phone))
                            self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: phone))
                            
                            mode = .sfp(.banksAndCountries(phone: phone))
                            
                            /*
                            withAnimation {
                                
                                
                                
                           
                                
                                let banksData = model.bankList.value
                                let bankSection = ContactsBanksSectionViewModel(model, bankData: banksData)
                                
                                let countiesData = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
                                let countriesSection = ContactsCountrySectionViewModel(countriesList: countiesData, model: model)
                                
                                let collapsable: [ContactsSectionCollapsableViewModel] = [bankSection, countriesSection]
                                
                                self.mode = .banks(.init(model, phone: phone), collapsable)
                            }
                             */
                            
                        } else {
                           
                            if let text = text {
                                
                                contactsSection?.filter.value = text
                                //TODO: hide latest payments section

                            } else {
                                
                                contactsSection?.filter.value = nil
                                //TODO: show latest payments section
                                
                                
                                /*
                                withAnimation(.easeInOut(duration: 1)) {
                                    
                                    self.mode = .contacts(.init(model, isBaseButtons: false, filter: .including([.phone])), .init(model))
                                }
                                 */
                            }
                        }
                        
                    case .banksAndCountries:
                        mode = .sfp(.contacts)
                    }
                    
                case let .select(select):
                    //TODO: update filters
                    break
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
                        self.action.send(ContactsViewModelAction.PaymentRequested(source: .latestPayment(payload.latestPayment)))
                        
                    case let payload as ContactsSectionViewModelAction.Contacts.ItemDidTapped:
                        switch mode {
                        case .sfp:
                            let formattedPhone = searchBar.textField.phoneNumberFormatter.partialFormatter("+\(payload.phone)")
                            self.searchBar.textField.text = formattedPhone
                            
                        case let .select(_, parameterId):
                            self.action.send(ContactsViewModelAction.ContactPhoneSelected(phone: payload.phone, parameterId: parameterId))
                        }
                        
                    case let payload as ContactsSectionViewModelAction.BanksPreffered.ItemDidTapped:
                        handleBankDidTapped(bank: payload.bank)
                        
                    case let payload as ContactsSectionViewModelAction.Banks.ItemDidTapped:
                        switch mode {
                        case .sfp:
                            handleBankDidTapped(bank: payload.bank)
                            
                        case let .select(_, parameterId):
                            self.action.send(ContactsViewModelAction.BankSelected(bank: payload.bank, parameterId: parameterId))
                        }
                        
                        
                    case let payload as ContactsSectionViewModelAction.Countries.ItemDidTapped:
                        
                        switch mode {
                        case let .sfp(phase):
                            switch phase {
                            case .banksAndCountries(phone: let phone):
                                self.action.send(ContactsViewModelAction.PaymentRequested(source: .abroad(phone: phone, country: payload.country)))
                                
                            default:
                                break
                            }
                            
                        case let .select(_, parameterId):
                            self.action.send(ContactsViewModelAction.CountrySelected(country: payload.country, parameterId: parameterId))
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
        
        case sfp(Phase)
        case select(Select, Payments.Parameter.ID)
        
        enum Phase {
            
            case contacts
            case banksAndCountries(phone: String)
        }
        
        enum Select {
            
            case contacts
            case banks
            case counties
        }
        
        var visibleSectionsTypes: [ContactsSectionViewModel.Kind] {
            
            switch self {
            case let .sfp(phase):
                switch phase {
                case .contacts:
                    return [.latestPayments, .contacts]
                    
                case .banksAndCountries:
                    return [.banksPreferred, .banks, .countries]
                }
                
            case let .select(select, _):
                switch select {
                case .contacts: return [.contacts]
                case .banks: return [.banks]
                case .counties: return [.countries]
                }
            }
        }
    }
}

//MARK: - Reducers

extension ContactsViewModel {
    
    func sections(for mode: Mode, model: Model) -> [ContactsSectionViewModel] {
        
        var result = [ContactsSectionViewModel]()
        
        switch mode {
        case .sfp:
            result.append(ContactsLatestPaymentsSectionViewModel(model: model, including: [.phone]))
            result.append(ContactsListSectionViewModel(model))
            result.append(ContactsBanksPrefferedSectionViewModel(model, phone: nil))
            result.append(ContactsBanksSectionViewModel(model, bankData: []))
            result.append(ContactsCountriesSectionViewModel(countriesList: [], model: model))

        case let .select(select, _):
            switch select {
            case .contacts:
                result.append(ContactsListSectionViewModel(model))
                
            case .banks:
                result.append(ContactsBanksSectionViewModel(model, bankData: []))
                
            case .counties:
                result.append(ContactsCountriesSectionViewModel(countriesList: [], model: model))
            }
        }
        
        return result
        
    }
    
    func visible(sections: [ContactsSectionViewModel], mode: Mode) -> [ContactsSectionViewModel] {
        
        sections.filter({ mode.visibleSectionsTypes.contains($0.type )})
    }
}

//MARK: - Helpers

extension ContactsViewModel {
    
    private var contactsSection: ContactsListSectionViewModel? {
        
        guard let contactsSection = sections.compactMap({ $0 as? ContactsListSectionViewModel }).first else {
            return nil
        }
        return contactsSection
    }
    
    func handleBankDidTapped(bank: BankData) {
        
        guard let phone = searchBar.phone else {
            
            return
        }
        
        switch bank.bankType {
        case .sfp:
            self.action.send(ContactsViewModelAction.PaymentRequested(source: .sfp(phone: phone, bank: bank)))
            
        case .direct:
            guard let country = self.model.countriesList.value.first(where: { $0.id == bank.bankCountry}) else {
                return
            }
            self.action.send(ContactsViewModelAction.PaymentRequested(source: .direct(phone: phone, bank: bank, country: country)))
            
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
        let parameterId: Payments.Parameter.ID
    }
    
    struct BankSelected: Action {
        
        let bank: BankData
        let parameterId: Payments.Parameter.ID
    }
    
    struct CountrySelected: Action {
        
        let country: CountryData
        let parameterId: Payments.Parameter.ID
    }
   
}

//MARK: - Samples

extension ContactsViewModel {
    /*
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)), mode: .contactsSearch(.init(.emptyMock, selfContact: .init(fullName: "name", image: nil, phone: "phone", icon: nil, action: {}), contacts: [])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)), mode: .contacts(.init(.emptyMock, items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))], isBaseButtons: false, filter: nil), .init(.emptyMock, selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
     */
    
    static let sampleBanks = ContactsBanksSectionViewModel(.emptyMock, header: .init(kind: .banks), items: [.sampleItem], mode: .normal, options: .sample)
    
    static let sampleHeader = ContactsSectionCollapsableViewModel.HeaderViewModel(kind: .country)
}

extension ContactsSectionCollapsableViewModel.ItemViewModel {
    
    static let sampleItem = ContactsSectionCollapsableViewModel.ItemViewModel(title: "Банк", image: .ic24Bank, bankType: .sfp, action: {})
}

extension ContactsSectionCollapsableViewModel {
    
    static let sampleHeader = ContactsSectionCollapsableViewModel.HeaderViewModel(kind: .country)
}

extension ContactsSectionCollapsableViewModel.HeaderViewModel {
    
    static let sampleHeader = ContactsSectionCollapsableViewModel.HeaderViewModel(kind: .banks)
}
