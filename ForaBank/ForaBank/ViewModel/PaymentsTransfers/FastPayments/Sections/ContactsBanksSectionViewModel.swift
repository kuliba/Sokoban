//
//  ContactsBanksSectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine
import SwiftUI
import TextFieldComponent

class ContactsBanksSectionViewModel: ContactsSectionCollapsableViewModel {
    
    override var type: ContactsSectionViewModel.Kind { .banks }
    
    @Published var searchTextField: RegularFieldViewModel?
    @Published var options: OptionSelectorView.ViewModel
    @Published var visible: [ContactsItemViewModel]
    let filter: CurrentValueSubject<String?, Never>
    let phone: CurrentValueSubject<String?, Never>
    @Published var searchPlaceholder: SearchPlaceholder? = nil
    
    private let items: CurrentValueSubject<[ContactsItemViewModel], Never>
    private let bankType: CurrentValueSubject<BankType?, Never>
    
    private let searchTextFieldFactory: () -> RegularFieldViewModel
    
    private init(_ model: Model, header: ContactsSectionHeaderView.ViewModel, isCollapsed: Bool, mode: Mode, searchTextField: RegularFieldViewModel?, options: OptionSelectorView.ViewModel, visible: [ContactsItemViewModel], items: [ContactsItemViewModel], bankType: BankType? = nil, phone: String?, filter: String? = nil, searchTextFieldFactory: @escaping () -> RegularFieldViewModel) {
        
        self.searchTextField = searchTextField
        self.options = options
        self.visible = visible
        self.items = .init(items)
        self.phone = .init(phone)
        self.filter = .init(filter)
        self.bankType = .init(bankType)
        self.searchTextFieldFactory = searchTextFieldFactory

        super.init(header: header, isCollapsed: isCollapsed, mode: mode, model: model)
    }
    
    convenience init(_ model: Model, mode: Mode, phone: String?, bankDictionary: BankDictionary, searchTextFieldFactory: @escaping () -> RegularFieldViewModel) {
        
        let options = Self.createOptionViewModel()
        self.init(model, header: .init(kind: .banks), isCollapsed: true, mode: mode, searchTextField: nil, options: options, visible: [], items: [], phone: phone, searchTextFieldFactory: searchTextFieldFactory)
        
        switch bankDictionary {
        case .banks:
            self.items.value = Self.reduce(bankList: model.bankList.value, preferred: model.prefferedBanksList.value) { [weak self]  bank in
                { self?.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bank.id)) }
            }
            
        case .banksFullInfo:
            self.items.value = Self.reduceBanksFullInfo(bankList: model.dictionaryFullBankInfoPrefferedFirstList()) { [weak self]  bank in
                {
                    self?.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bank.bic))
                }
            }
        }
    }
    
    enum BankDictionary {
        
        case banks
        case banksFullInfo
    }
    
    override func bind() {
        super.bind()
        
        phone
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] phone in
                
                guard let phone = phone else {
                    return
                }
                
                if phone.digits.first == "7" {
                    
                    self.options.selected = BankType.sfp.rawValue
                    bankType.value = BankType.sfp
                    
                } else {
                    
                    self.options.selected = BankType.direct.rawValue
                    bankType.value = BankType.direct
                }
            }.store(in: &bindings)
        
        items
            .combineLatest(bankType, filter)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] items, bankType, filter in
                
                if items.isEmpty == false {
                    
                    withAnimation {
                        
                        let banksByPhone = model.paymentsByPhone.value[phone.value?.digits ?? ""]?
                            .sorted(by: { $0.defaultBank && $1.defaultBank })
                        
                        let banksID = banksByPhone?.compactMap({ $0.bankId })
                        
                        let sortedBanks = Self.reduce(
                            bankList: model.bankList.value,
                            preferred: banksID ?? []
                        ) { [weak self]  bank in
                            { self?.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bank.id)) }
                        }
                        
                        let filterBanks = Self.reduce(
                            items: sortedBanks,
                            filterByType: bankType,
                            filterByName: filter
                        )
                        
                        if filterBanks.count > 0 {
                            
                            self.searchPlaceholder = nil
                            visible = filterBanks
                            if #available(iOS 14.5, *) {} else { objectWillChange.send() }
                            
                        } else {
                            
                            visible = []
                            self.searchPlaceholder = .init()
                        }
                    }
                    
                } else {
                    
                    withAnimation {
  
                        visible = (0..<8).map { _ in ContactsPlaceholderItemView.ViewModel(style: .bank) }
                    }
                }
 
            }.store(in: &bindings)
        
        options.$selected
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] selected in
                
                bankType.value = BankType(rawValue: selected)
                
            }.store(in: &bindings)
        
        bankType
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] bankType in
                
                withAnimation {
                    
                    if bankType == .sfp {
                        
                        header.icon = .ic24Sbp
                        
                    } else {
                        
                        header.icon = .ic24Bank
                    }
                }
                
            }.store(in: &bindings)
        
        header.action
            .compactMap { $0 as? ContactsSectionViewModelAction.Collapsable.SearchDidTapped }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                let searchTextFieldViewModel = searchTextFieldFactory()
                bind(searchTextField: searchTextFieldViewModel)
                
                withAnimation {
                    
                    self.header.isCollapsed = true
                    self.searchTextField = searchTextFieldViewModel
                }
            }
            .store(in: &bindings)
    }
    
    func bind(searchTextField: RegularFieldViewModel) {
        
        searchTextField.$state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case let .editing(textState):
                    self.filter.value = textState.text
                    
                case let .noFocus(text):
                    self.filter.value = text
                    
                case .placeholder:
                    withAnimation {
                        
                        self.filter.value = nil
                    }
                }
            }
            .store(in: &bindings)
    }
    
    func cancelSearch() {
        
        withAnimation {
            
            self.searchTextField = nil
            self.filter.value = nil
        }
    }
}

//MARK: - SearchPlaceholder

extension ContactsBanksSectionViewModel {

    struct SearchPlaceholder {
    
        let image: Image = .ic24Search
        let title = "Не удалось найти банк"
        let description = "Попробуйте изменить название банка"
    }
}

//MARK: - Reducers

extension ContactsBanksSectionViewModel {
    
    static func reduce(
        bankList: [BankData],
        preferred: [String],
        action: @escaping (BankData) -> () -> Void
    ) -> [ContactsItemViewModel] {
        
        let preferredBanks = preferred.compactMap { bankId in bankList.first(where: { $0.id == bankId }) }
        let otherBanks = bankList.filter{ preferred.contains($0.id) == false }
            .sorted(by: {$0.memberNameRus.lowercased() < $1.memberNameRus.lowercased()})
            .sorted(by: {$0.memberNameRus.localizedCaseInsensitiveCompare($1.memberNameRus) == .orderedAscending})
        
        let allBanks = preferredBanks + otherBanks
        
        return allBanks.map{ ContactsBankItemView.ViewModel(id: $0.id, icon: $0.svgImage.image, name: $0.memberNameRus, subtitle: nil, type: $0.bankType, action: action($0)) }
    }
    
    static func reduceBanksFullInfo(
        bankList: [BankFullInfoData],
        action: @escaping (BankFullInfoData) -> () -> Void
    ) -> [ContactsItemViewModel] {
        
        bankList.map{ ContactsBankItemView.ViewModel(
            icon: $0.svgImage.image,
            name: $0.rusName ?? $0.fullName,
            subtitle: $0.bic,
            type: .sfp,
            action: action($0)
        )}
    }
    
    static func reduce(
        items: [ContactsItemViewModel],
        filterByType: BankType? = nil,
        filterByName: String? = nil
    ) -> [ContactsItemViewModel] {
        
        var filteredItems = items.compactMap({ $0 as? ContactsBankItemView.ViewModel })
        
        if let bankType = filterByType {
            
            filteredItems = filteredItems.filter({ $0.type == bankType })
        }
        
        if let name = filterByName, name != "" {
            
            filteredItems = filteredItems.filter({ item in
                
                if name.isNumeric, let subtitle = item.subtitle {
                    
                    return subtitle.localizedStandardContains(name)
                } else {
                    
                    return item.name.localizedStandardContains(name)
                }

            })
        }

        return filteredItems
    }
}

//MARK: - Helpers

extension ContactsBanksSectionViewModel {
    
    static func createOptionViewModel() -> OptionSelectorView.ViewModel {
        
        var options = BankType.valid.map { bankType in
            
            return Option(id: bankType.rawValue, name: bankType.name)
        }
        
        options.append(Option(id: "all", name: "Все"))
        
        let firstOption = options[0].id
        
        return .init(options: options, selected: firstOption, style: .template, mode: .auto)
    }
}

//MARK: - Action

extension ContactsSectionViewModelAction {
    
    enum Banks {
    
        struct ItemDidTapped: Action {
            
            let bankId: BankData.ID
        }
    }
}

//MARK: - Preview Content

extension ContactsBanksSectionViewModel {
    
    static let sample = ContactsBanksSectionViewModel(.emptyMock, header: .init(kind: .banks), isCollapsed: true, mode: .fastPayment, searchTextField: nil, options: .sample, visible: [ContactsBankItemView.ViewModel.sample, ContactsBankItemView.ViewModel.sample], items: [ContactsBankItemView.ViewModel.sample, ContactsBankItemView.ViewModel.sample], phone: nil, searchTextFieldFactory: { .bank() })
}

