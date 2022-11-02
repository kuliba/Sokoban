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
        case banks(ContactsTopBanksSectionViewModel?, [CollapsableSectionViewModel])
        case banksSearch([CollapsableSectionViewModel])
    }
    
    init(_ model: Model, searchBar: SearchBarView.ViewModel, mode: Mode) {
        
        self.model = model
        self.searchBar = searchBar
        self.mode = mode
    }
    
    convenience init(_ model: Model) {
 
        let filterSymbols: [Character] = [Character("-"), Character("("), Character(")"), Character("+")]
        let toolBar: TextFieldPhoneNumberView.ToolbarViewModel = .init(doneButton: .init(isEnabled: true) { UIApplication.shared.endEditing() },
                                                                  closeButton: .init(isEnabled: true, action: { UIApplication.shared.endEditing() }))
        let textFieldViewModel: TextFieldPhoneNumberView.ViewModel = .init(placeHolder: .contacts, toolbar: toolBar, filterSymbols: filterSymbols, phoneNumberFirstDigitReplaceList: [.init(from: "8", to: "7"), .init(from: "9", to: "+7 9")])
        let searchBar: SearchBarView.ViewModel = .init(textFieldPhoneNumberView: textFieldViewModel)
        
        self.init(model, searchBar: searchBar, mode: .contacts(nil, .init(model)))
        bind()
    }
    
    private func bind() {
        
        //MARK: Mode
        
        $mode
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] mode in
                
                bindMode(mode: mode)
                
            }.store(in: &bindings)
        
        //MARK: SearchViewModel
        
        searchBar.textFieldPhoneNumberView.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                if text != nil, text != "" {
                    mode = .contactsSearch(.init(model, filterText: text))
                    
                } else {
                    
                    let latestPaymentsFilterred = model.latestPayments.value.filter({$0.type == .phone})
                    
                    withAnimation(.easeInOut(duration: 1)) {
                        
                        self.mode = .contacts(.init(model, latest: latestPaymentsFilterred, filterType: [.phone]), .init(model))
                    }
                }
                
            }.store(in: &bindings)
        
        searchBar.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as SearchBarViewModelAction.ClearTextField:
                    self.searchBar.textFieldPhoneNumberView.text = nil
                    
                case let payload as SearchBarViewModelAction.Number.isValidation:
                    
                    if payload.isValidation {
                        
                        guard let phone = searchBar.textFieldPhoneNumberView.text else {
                            return
                        }
                        
                        withAnimation {
                            
                            self.feedbackGenerator.notificationOccurred(.success)
                            self.searchBar.state = .idle
                            
                            if let phone = searchBar.textFieldPhoneNumberView.text {
                                
                                self.model.action.send(ModelAction.BankClient.Request(phone: phone))
                                self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: phone))
                            }
                            
                            let banksData = model.bankList.value
                            let bankSection = ContactsBanksSectionViewModel(model, bankData: banksData)
                            
                            let countiesData = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
                            let countriesSection = ContactsCountrySectionViewModel(countriesList: countiesData)
                            
                            let collapsable: [CollapsableSectionViewModel] = [bankSection, countriesSection]
                            
                            self.mode = .banks(.init(model, selectPhone: phone), collapsable)
                        }
                        
                    } else {
                        
                        guard case .banks(_, _) = mode else {
                            return
                        }
                        
                        let latestPayments = model.latestPayments.value
                        
                        withAnimation(.easeInOut(duration: 1)) {
                            
                            self.mode = .contacts(.init(model, latest: latestPayments, filterType: [.phone]), .init(model))
                        }
                    }
                    
                default: break
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
                        self.searchBar.textFieldPhoneNumberView.text = payload.phone
                        
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
                            
                        case let payload as ContactsListViewModelAction.ContactSelect:
                            self.searchBar.textFieldPhoneNumberView.text = payload.phone
                            
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
                        self.searchBar.textFieldPhoneNumberView.text = payload.phone
                        
                    default: break
                        
                    }
                    
                }.store(in: &bindings)
            
        case .banks(let topBanks, let collapsableSection):
            
            if let topBanks = topBanks {
                
                topBanks.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                            
                        case _ as ContactsTopBanksSectionViewModelAction.TopBanksDidTapped:
                            //TODO: setup action link to paymentView
                            break
                            
                        default: break
                        }
                    }.store(in: &bindings)
            }
            
            for section in collapsableSection {
                
                section.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as ContactsBanksSectionViewModelAction.BankDidTapped:
                            //TODO: setup action link to paymentView
                            break
                            
                        case let payload as ContactsCountrySectionViewModelAction.CountryDidTapped:
                            
                            if let country = model.countriesList.value.first(where: {$0.id == payload.countryId}), let phone = searchBar.textFieldPhoneNumberView.text {
                                self.link = .init(type: .country( .init(country: country.name, operatorsViewModel: .init(closeAction: {}, template: nil), paymentType: .withOutAddress(withOutViewModel: .init(phoneNumber: phone)))))
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
    
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks, phoneNumberFirstDigitReplaceList: [])), mode: .contactsSearch(.init(.emptyMock, selfContact: .init(fullName: "name", image: nil, phone: "phone", icon: nil, action: {}), contacts: [])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks, phoneNumberFirstDigitReplaceList: [])), mode: .contacts(.init(.emptyMock, items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))]), .init(.emptyMock, selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, action: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, action: {})])))
    
    static let sampleBanks = ContactsBanksSectionViewModel(.emptyMock, header: .init(kind: .banks), items: [.sampleItem], mode: .normal, options: .sample)
    
    static let sampleHeader = CollapsableSectionViewModel.HeaderViewModel(kind: .country)
}

extension CollapsableSectionViewModel.ItemViewModel {
    
    static let sampleItem = CollapsableSectionViewModel.ItemViewModel(title: "Банк", image: .ic24Bank, bankType: .sfp, action: {})
}

extension CollapsableSectionViewModel {
    
    static let sampleHeader = CollapsableSectionViewModel.HeaderViewModel(kind: .country)
}

extension CollapsableSectionViewModel.HeaderViewModel {
    
    static let sampleHeader = CollapsableSectionViewModel.HeaderViewModel(kind: .banks)
}
