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
    @Published var searchBar: SearchBarView.ViewModel
    @Published var mode: Mode
    @Published var link: Link?
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    enum Mode {
        
        case contacts(LatestPaymentsView.ViewModel?, ContactsListViewModel)
        case contactsSearch(ContactsListViewModel)
        case banks(ContactsTopBanksSectionViewModel?, [ContactsSectionViewModel])
        case banksSearch([ContactsSectionViewModel])
    }
    
    init(_ model: Model, searchBar: SearchBarView.ViewModel, mode: Mode) {
        
        self.model = model
        self.searchBar = searchBar
        self.mode = mode
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    convenience init(_ model: Model) {
 
        self.init(model, searchBar: .init(textFieldPhoneNumberView: .init(.contacts)), mode: .contacts(nil, .init(model)))
        
        bind()
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit")
    }
    
    private func bind() {
        
        $mode
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] mode in
                
                bindMode(mode: mode)
                
            }.store(in: &bindings)
        
        searchBar.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                if let phone = searchBar.phone {
                    
                    withAnimation {
                        
                        self.feedbackGenerator.notificationOccurred(.success)
                        self.searchBar.action.send(SearchBarViewModelAction.Idle())
                        
                        self.model.action.send(ModelAction.BankClient.Request(phone: phone))
                        self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: phone))
                        
                        let banksData = model.bankList.value
                        let bankSection = ContactsBanksSectionViewModel(model, bankData: banksData)
                        
                        let countiesData = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
                        let countriesSection = ContactsCountrySectionViewModel(countriesList: countiesData)
                        
                        let collapsable: [ContactsSectionViewModel] = [bankSection, countriesSection]
                        
                        self.mode = .banks(.init(model, selectPhone: phone), collapsable)
                    }
                    
                } else {
                   
                    if let text = text {
                        
                        mode = .contactsSearch(.init(model, filterText: text))

                    } else {
                        
                        withAnimation(.easeInOut(duration: 1)) {
                            
                            self.mode = .contacts(.init(model, isBaseButtons: false, filter: .including([.phone])), .init(model))
                        }
                    }
                }
 
            }.store(in: &bindings)
    }
    
    private func bindMode(mode: Mode) {
        
        switch mode {
        case .contacts(let latestPayments, let contacts):
            
            contacts.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ContactsListViewModelAction.ContactSelect:
                        self.searchBar.textField.text = payload.phone
                        
                    default: break
                    }
                    
                }.store(in: &bindings)
            
            if let latestPayments = latestPayments {
                
                latestPayments.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let item as LatestPaymentsViewModelAction.ButtonTapped.LatestPayment:
                            //TODO: setup action link to paymentView
                            break
                            
                        default: break
                        }
                        
                    }.store(in: &bindings)
            }
            
        case .contactsSearch(let contacts):
            
            contacts.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ContactsListViewModelAction.ContactSelect:
                        self.searchBar.textField.text = payload.phone
                        
                    default: break
                    }
                    
                }.store(in: &bindings)
            
        case .banks(let topBanks, let collapsableSection):
            
            if let topBanks = topBanks {
                
                topBanks.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as ContactsTopBanksSectionViewModelAction.TopBanksDidTapped:
                            
                            if let bank = model.bankList.value.first(where: {$0.memberId == payload.bankId}), bank.bankType == .direct, let phone = searchBar.textField.text, let country = model.countriesList.value.first(where: {$0.code == "AM" }) {
                                
                                self.link = .init(type: .country(.init(phone: phone, country: country, bank: bank, operatorsViewModel: .init(closeAction: { [weak self] in
                                    self?.link = nil
                                    
                                }, template: nil))))

                            }
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
            
            for section in collapsableSection {
                
                section.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as ContactsBanksSectionViewModelAction.BankDidTapped:
                            
                            if let bank = model.bankList.value.first(where: {$0.id == payload.bankId}), bank.bankType == .direct, let phone = searchBar.textField.text, let country = model.countriesList.value.first(where: {$0.code == "AM" }) {
                                
                                self.link = .init(type: .country(.init(phone: phone, country: country, bank: bank, operatorsViewModel: .init(closeAction: { [weak self] in
                                    self?.link = nil
                                }, template: nil))))
                            }
                            
                        case let payload as ContactsCountrySectionViewModelAction.CountryDidTapped:
                            
                            if let country = model.countriesList.value.first(where: {$0.id == payload.countryId}), let phone = searchBar.textField.text {
                                self.link = .init(type: .country(.init(phone: phone, country: country, bank: nil, operatorsViewModel: .init(closeAction: { [weak self] in
                                    self?.link = nil
                                }, template: nil))))
                            }
                        default: break
                        }
                        
                    }.store(in: &bindings)
            }
            
        default: break
        }
    }
}

extension ContactsViewModel {
    
    struct Link: Identifiable, Equatable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case country(CountryPaymentView.ViewModel)
        }
        
        static func == (lhs: ContactsViewModel.Link, rhs: ContactsViewModel.Link) -> Bool {
            lhs.id == rhs.id
            
        }
    }
}

extension ContactsViewModel {
    
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)), mode: .contactsSearch(.init(.emptyMock, selfContact: .init(fullName: "name", image: nil, phone: "phone", icon: nil, action: {}), contacts: [])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)), mode: .contacts(.init(.emptyMock, items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))], isBaseButtons: false, filter: nil), .init(.emptyMock, selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleBanks = ContactsBanksSectionViewModel(.emptyMock, header: .init(kind: .banks), items: [.sampleItem], mode: .normal, options: .sample)
    
    static let sampleHeader = ContactsSectionViewModel.HeaderViewModel(kind: .country)
}

extension ContactsSectionViewModel.ItemViewModel {
    
    static let sampleItem = ContactsSectionViewModel.ItemViewModel(title: "Банк", image: .ic24Bank, bankType: .sfp, action: {})
}

extension ContactsSectionViewModel {
    
    static let sampleHeader = ContactsSectionViewModel.HeaderViewModel(kind: .country)
}

extension ContactsSectionViewModel.HeaderViewModel {
    
    static let sampleHeader = ContactsSectionViewModel.HeaderViewModel(kind: .banks)
}
