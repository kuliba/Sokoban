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

    private var items: [ContactsItemViewModel]
    private var bankType: BankType? { BankType(rawValue: options.selected) }
    
    init(_ model: Model, header: ContactsSectionHeaderView.ViewModel, isCollapsed: Bool, mode: Mode, searchBar: SearchBarView.ViewModel?, options: OptionSelectorView.ViewModel, visible: [ContactsItemViewModel], items: [ContactsItemViewModel], filter: String? = nil) {
        
        self.searchBar = searchBar
        self.options = options
        self.visible = visible
        self.items = items
        self.filter = .init(filter)

        super.init(header: header, isCollapsed: isCollapsed, mode: mode, model: model)
    }
    
    convenience init(_ model: Model, mode: Mode) {
        
        let options = Self.createOptionViewModel()
        let visiblePlaceholders = Array(repeating: ContactsPlaceholderItemView.ViewModel(style: .bank), count: 8)
        self.init(model, header: .init(kind: .banks), isCollapsed: true, mode: mode, searchBar: nil, options: options, visible: visiblePlaceholders, items: [])

        Task {
            
            items = await Self.reduce(bankList: model.bankList.value) { [weak self]  bank in
                { self?.action.send(ContactsSectionViewModelAction.Banks.ItemDidTapped(bank: bank)) }
            }
            
            await MainActor.run {
                
                withAnimation {
                    
                    visible = Self.reduce(items: items, filterByType: bankType)
                }
            }
        }
  
        bind()
    }
    
    override func bind() {
        super.bind()
        
        options.$selected
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] selected in
                
                withAnimation {
                    
                    visible = Self.reduce(items: items, filterByType: bankType)
                    
                    if bankType == .sfp {
                        
                        header.icon = .ic24SBP
                        
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
                        
                        searchBar = searchBarViewModel
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(searchBar: SearchBarView.ViewModel) {
        
        self.header.isCollapsed = true
        
        searchBar.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case .idle:
                    self.searchBar = nil
                    
                    withAnimation {
                        
                        visible = Self.reduce(items: items, filterByType: bankType)
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        searchBar.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                
                withAnimation {
                    
                    visible = Self.reduce(items: items, filterByType: bankType, filterByName: text)
                }
                
            }.store(in: &bindings)
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
            
            let bank: BankData
        }
    }
}
