//
//  ContactsBanksSectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine
import SwiftUI

class ContactsBanksSectionViewModel: ContactsSectionCollapsableViewModel {
    
    override var type: ContactsSectionViewModel.Kind { .banks }
    
    @Published var searchBar: SearchBarView.ViewModel?
    @Published var options: OptionSelectorView.ViewModel
    @Published var visible: [ContactsItemViewModel]
    let filter: CurrentValueSubject<String?, Never>
    let phone: CurrentValueSubject<String?, Never>
    @Published var searchPlaceholder: SearchPlaceholder? = nil
    
    private let items: CurrentValueSubject<[ContactsItemViewModel], Never>
    private let bankType: CurrentValueSubject<BankType?, Never>
    
    init(_ model: Model, header: ContactsSectionHeaderView.ViewModel, isCollapsed: Bool, mode: Mode, searchBar: SearchBarView.ViewModel?, options: OptionSelectorView.ViewModel, visible: [ContactsItemViewModel], items: [ContactsItemViewModel], bankType: BankType? = nil, phone: String?, filter: String? = nil) {
        
        self.searchBar = searchBar
        self.options = options
        self.visible = visible
        self.items = .init(items)
        self.phone = .init(phone)
        self.filter = .init(filter)
        self.bankType = .init(bankType)

        super.init(header: header, isCollapsed: isCollapsed, mode: mode, model: model)
    }
    
    convenience init(_ model: Model, mode: Mode, phone: String?) {
        
        let options = Self.createOptionViewModel()
        self.init(model, header: .init(kind: .banks), isCollapsed: true, mode: mode, searchBar: nil, options: options, visible: [], items: [], phone: phone)
        
        Task.detached(priority: .userInitiated) {
            
            self.items.value = await Self.reduce(bankList: model.bankList.value) { [weak self]  bank in
                { self?.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bankId: bank.id)) }
            }
        }
    }
    
    override func bind() {
        super.bind()
        
        phone
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                if text?.digits.first == "7" {
                    
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
            .sink { [unowned self] data in
                
                let items = data.0
                let bankType = data.1
                let filter = data.2
                
                if items.isEmpty == false {
                    
                    withAnimation {
                        
                        let filterBanks = Self.reduce(items: items, filterByType: bankType, filterByName: filter)
                        
                        if filterBanks.count > 0 {
                            
                            self.searchPlaceholder = nil
                            visible = filterBanks
                            
                        } else {
                            
                            visible = []
                            self.searchPlaceholder = .init()
                        }
                    }
                    
                } else {
                    
                    withAnimation {
  
                        visible = Array(repeating: ContactsPlaceholderItemView.ViewModel(style: .bank), count: 8)
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
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ContactsSectionViewModelAction.Collapsable.SearchDidTapped:
                    let searchBarViewModel = SearchBarView.ViewModel(textFieldPhoneNumberView: .init(.banks))
                    bind(searchBar: searchBarViewModel)
                    withAnimation {
                        
                        self.header.isCollapsed = true
                        searchBar = searchBarViewModel
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(searchBar: SearchBarView.ViewModel) {
        
        searchBar.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as SearchBarViewModelAction.DismissKeyboard:
                    withAnimation {
                        
                        self.searchBar = nil
                        filter.value = nil
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        searchBar.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                filter.value = text
                
            }.store(in: &bindings)
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
    
    static func reduce(bankList: [BankData], action: @escaping (BankData) -> () -> Void) async -> [ContactsItemViewModel] {
        
        return bankList
            .map({ ContactsBankItemView.ViewModel(id: $0.id, icon: $0.svgImage.image, name: $0.memberNameRus, type: $0.bankType, action: action($0)) })
            .sorted(by: {$0.name.lowercased() < $1.name.lowercased()})
            .sorted(by: {$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending})
    }
    
    static func reduce(items: [ContactsItemViewModel], filterByType: BankType? = nil, filterByName: String? = nil) -> [ContactsItemViewModel] {
        
        var filterredItems = items.compactMap({ $0 as? ContactsBankItemView.ViewModel })
        
        if let bankType = filterByType {
            
            filterredItems = filterredItems.filter({$0.type == bankType})
        }
        
        if let name = filterByName {
            
            filterredItems = filterredItems.filter({ $0.name.localizedStandardContains(name) })
        }

        return filterredItems
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
