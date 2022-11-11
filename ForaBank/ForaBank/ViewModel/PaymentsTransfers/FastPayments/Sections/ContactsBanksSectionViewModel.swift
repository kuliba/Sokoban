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
    
    @Published var mode: Mode
    @Published var options: OptionSelectorView.ViewModel
    var bankType: BankType? { BankType(rawValue: options.selected) }
    
    private var allItems: [ContactsSectionCollapsableViewModel.ItemViewModel]

    enum Mode {
        
        case normal
        case search(SearchBarView.ViewModel)
    }
    
    init(_ model: Model, header: ContactsSectionCollapsableViewModel.HeaderViewModel, items: [ContactsSectionCollapsableViewModel.ItemViewModel], mode: Mode, options: OptionSelectorView.ViewModel) {
        
        self.mode = mode
        self.options = options
        self.allItems = items
        super.init(header: header, items: items, model: model)
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init")
    }
    
    convenience init(_ model: Model, bankData: [BankData]) {
        
        let options = Self.createOptionViewModel()
        self.init(model, header: .init(kind: .banks), items: [], mode: .normal, options: options)
        
        Task {
            
            self.allItems = await Self.reduce(bankList: model.bankList.value) { [weak self]  bank in
                { self?.action.send(ContactsBanksSectionViewModelAction.BankDidTapped(bank: bank)) }
            }
            
            await MainActor.run {
                
                self.items = Self.reduce(items: allItems, filterByType: bankType)
            }
        }
  
        bind()
    }
    
    override func bind() {
        super.bind()
        
        options.$selected
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] selected in
                
                self.items = Self.reduce(items: allItems, filterByType: bankType)
                
                if bankType == .sfp {
                    
                    header.icon = .ic24SBP
                    
                } else {
                    
                    header.icon = .ic24Bank
                }
                
            }.store(in: &bindings)
        
        header.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as HeaderViewModelAction.SearchDidTapped:
                    self.mode = .search(.init(textFieldPhoneNumberView: .init(.banks)))
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        $mode
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] mode in
                
                switch mode {
                case .search(let search):
                    
                    self.header.isCollapsed = true
                    
                    search.$state
                        .dropFirst()
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] state in
                            
                            switch state {
                            case .idle:
                                self.mode = .normal
                                
                            default:
                                break
                            }
                            
                        }.store(in: &bindings)
                    
                    search.textField.$text
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] text in
                            
                            self.items = Self.reduce(items: allItems, filterByType: bankType, filterByName: text)
                            
                        }.store(in: &bindings)
                    
                case .normal:
                    self.items = Self.reduce(items: allItems, filterByType: bankType)
                    
                }
            }.store(in: &bindings)
    }
}

//MARK: - Reducers

extension ContactsBanksSectionViewModel {
    
    static func reduce(bankList: [BankData], action: @escaping (BankData) -> () -> Void) async ->  [ContactsSectionCollapsableViewModel.ItemViewModel] {
        
        return bankList
            .map({ContactsSectionCollapsableViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: action($0))})
            .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
            .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
    }
    
    static func reduce(items: [ContactsSectionCollapsableViewModel.ItemViewModel], filterByType: BankType? = nil, filterByName: String? = nil) -> [ContactsSectionCollapsableViewModel.ItemViewModel] {
        
        var filterredItems = items
        
        if let bankType = filterByType {
            
            filterredItems = filterredItems.filter({$0.bankType == bankType})
        }
        
        if let name = filterByName {
            
            filterredItems = filterredItems.filter({ $0.title.localizedStandardContains(name) })
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

struct ContactsBanksSectionViewModelAction {
    
    struct BankDidTapped: Action {
        
        let bank: BankData
    }
}
