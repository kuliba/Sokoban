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
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    enum Mode {
        
        case contacts(LatestPaymentsView.ViewModel?, ContactsListViewModel)
        case contactsSearch(ContactsListViewModel)
        case banks(ContactsTopBanksSectionViewModel?, [CollapsableSectionViewModel])
        case banksSearch([CollapsableSectionViewModel])
    }
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(_ model: Model, searchBar: SearchBarView.ViewModel, mode: Mode) {
        
        self.model = model
        self.searchBar = searchBar
        self.mode = mode
    }
    
    convenience init(_ model: Model) {
        
        let searchBar: SearchBarView.ViewModel = .init(textFieldPhoneNumberView: .init(placeHolder: .contacts,
                                                                                       toolbar: .init(doneButton: .init(isEnabled: true) { UIApplication.shared.endEditing() },
                                                                                                      closeButton: .init(isEnabled: true, action: { UIApplication.shared.endEditing() })), filtersSymbols: [Character("-"), Character("("), Character(")"), Character("+")]))
        
        self.init(model, searchBar: searchBar, mode: .contacts(nil, .init(model)))
        
        bind()
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ContactsViewModelAction.SetupPhoneNumber:
                    self.searchBar.textFieldPhoneNumberView.text = payload.phone
                    
                case let payload as ContactsListViewModelAction.ContactSelect:
                    self.searchBar.textFieldPhoneNumberView.text = payload.phone
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        model.latestPayments
            .combineLatest(model.latestPaymentsUpdating)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                guard case .contacts(_, let contacts) = mode else {
                    return
                }
                
                let latestPayments = data.0
                
                let latestPaymentsFilterred = latestPayments.filter({ $0.type == .phone })
                
                withAnimation(.easeInOut(duration: 1)) {
                    
                    let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                    self.mode = .contacts(.init(model, items: items), contacts)
                }
                
            }.store(in: &bindings)
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                guard case .contacts(let latestPayments, let contacts) = mode else {
                    return
                }
                
                mode = .contacts(latestPayments, contacts)
                
            }.store(in: &bindings)
        
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
                        
                        let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                        self.mode = .contacts(.init(model, items: items), .init(model))
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
                        
                        withAnimation {
                            
                            self.feedbackGenerator.notificationOccurred(.success)
                            self.searchBar.state = .idle
                            
                            if let text = searchBar.textFieldPhoneNumberView.text {
                                
                                self.model.action.send(ModelAction.BankClient.Request(phone: text))
                                self.model.action.send(ModelAction.LatestPayments.BanksList.Request(phone: text))
                            }
                            
                            let banksData = model.bankList.value
                            let bankSection = BanksSectionCollapsableViewModel(model, bankData: banksData)
                            
                            let countiesData = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
                            let countriesSection = CountrySectionCollapsableViewModel(countriesList: countiesData)
                            
                            let collapsable: [CollapsableSectionViewModel] = [bankSection, countriesSection]
                            
                            self.mode = .banks(.init(model), collapsable)
                        }
                    } else {
                        
                        guard case .banks(_, _) = mode else {
                            return
                        }
                        
                        let latestPaymentsFilterred = model.latestPayments.value.filter({$0.type == .phone})
                        
                        withAnimation(.easeInOut(duration: 1)) {
                            
                            let items = itemsReduce(model: self.model, latest: latestPaymentsFilterred)
                            self.mode = .contacts(.init(model, items: items), .init(model))
                        }
                    }
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        //MARK: TopBanks
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.LatestPayments.BanksList.Response:
                    
                    switch payload.result {
                    case .success(let banks):
                        
                        let banks = self.reduce(model: model, banks: banks)
                        
                        let banksData = model.bankList.value
                        let bankSection = BanksSectionCollapsableViewModel(model, bankData: banksData)
                        
                        let countiesData = model.countriesList.value.filter({$0.paymentSystemIdList.contains({"DIRECT"}())})
                        let countriesSection = CountrySectionCollapsableViewModel(countriesList: countiesData)
                        
                        let collapsable: [CollapsableSectionViewModel] = [bankSection, countriesSection]
                        
                        
                        if let banks = banks {
                            
                            self.mode = .banks(.init(model, content: .banks(banks)), collapsable)
                        }
                        
                    case .failure:
                        break
                    }
                default: break
                }
            }.store(in: &bindings)
    }
    
    private func bindMode(mode: Mode) {
        
        switch mode {
        case .contacts(_, let contacts):
            
            contacts.$selfContact
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] contact in
                    
                    contact?.actionContact = { [unowned self] in
                        
                        if let phone = contact?.phone {
                            
                            action.send(ContactsListViewModelAction.ContactSelect(phone: phone))
                        }
                    }
                    
                }.store(in: &bindings)
            
            contacts.$contacts
                .receive(on: DispatchQueue.main)
                .sink { contacts in
                    
                    for contact in contacts {
                        contact.actionContact = { [unowned self] in
                            
                            action.send(ContactsListViewModelAction.ContactSelect(phone: contact.phone))
                        }
                    }
                }.store(in: &bindings)
            
        case .contactsSearch(let contacts):
            
            contacts.$contacts
                .receive(on: DispatchQueue.main)
                .sink { contacts in
                    
                    for contact in contacts {
                        contact.actionContact = { [unowned self] in
                            
                            action.send(ContactsListViewModelAction.ContactSelect(phone: contact.phone))
                        }
                    }
                }.store(in: &bindings)
            
        default: break
        }
    }
    
    func itemsReduce(model: Model, latest: [LatestPaymentData]) -> [LatestPaymentsView.ViewModel.ItemViewModel] {
        
        var itemViewModel = [LatestPaymentsView.ViewModel.ItemViewModel]()
        
        itemViewModel = latest.map({ latestPayment in
            
            if let latestPhone = latestPayment as? PaymentGeneralData {
                
                return LatestPaymentsView.ViewModel.ItemViewModel.latestPayment(.init(data: latestPayment, model: model, action: { [weak self] in
                    
                    self?.action.send(ContactsViewModelAction.SetupPhoneNumber(phone: latestPhone.phoneNumber))
                }))
            }
            
            return LatestPaymentsView.ViewModel.ItemViewModel.latestPayment(.init(data: latestPayment, model: model, action: {}))
        })
        
        return itemViewModel
    }
    
    func reduce(model: Model, banks: [PaymentPhoneData]) -> TopBanksViewModel? {
        
        let topBanksViewModel: TopBanksViewModel = .init(banks: [])
        
        var banksList: [TopBanksViewModel.Bank] = []
        
        banks.map({
            
            if let bankName = $0.bankName, let defaultBank = $0.defaultBank, let payment = $0.payment {
                
                let contact = payment ? model.contact(for: self.searchBar.text ?? "") : nil
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
    
    enum Link {
        
        case country(CountryPaymentView.ViewModel)
    }
}

enum ContactsViewModelAction {
    
    struct SetupPhoneNumber: Action {
        
        let phone: String
    }
}

extension ContactsViewModel {
    
    static let sample: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)), mode: .contactsSearch(.init(selfContact: .init(fullName: "name", image: nil, phone: "phone", icon: nil, actionContact: {}), contacts: [])))
    
    static let sampleLatestPayment: ContactsViewModel = .init(.emptyMock, searchBar: .init(textFieldPhoneNumberView: .init(placeHolder: .banks)), mode: .contacts(.init(.emptyMock, items: [.latestPayment(.init(id: 5, avatar: .icon(Image("ic24Smartphone"), .iconGray), topIcon: Image("azerFlag"), description: "+994 12 493 23 87", action: {}))]), .init(selfContact: .init(fullName: "Себе", image: nil, phone: "8 (925) 279 96-13", icon: nil, actionContact: {}), contacts: [.init(fullName: "Андрей Андропов", image: nil, phone: "+7 (903) 333-67-32", icon: nil, actionContact: {})])))
    
    static let sampleBanks = BanksSectionCollapsableViewModel(.emptyMock, header: .init(kind: .banks), items: [.sampleItem], mode: .normal, options: .sample)
    
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
