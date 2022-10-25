//
//  ContactsBanksSectionCollapsableViewModel.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 25.10.2022.
//

import Foundation
import Combine

class BanksSectionCollapsableViewModel: CollapsableSectionViewModel {
    
    @Published var mode: Mode
    @Published var options: OptionSelectorView.ViewModel?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(_ model: Model, header: CollapsableSectionViewModel.HeaderViewModel, items: [CollapsableSectionViewModel.ItemViewModel], mode: Mode, options: OptionSelectorView.ViewModel?) {
        
        self.model = model
        self.mode = mode
        self.options = options
        super.init(header: header, items: items)
    }
    
    convenience init(_ model: Model, bankData: [BankData]) {
        
        let items = Self.reduceBanks(banksData: bankData)
        let options = Self.createOptionViewModel()
        
        self.init(model, header: .init(kind: .banks), items: items, mode: .normal, options: options)
        bind()
    }
    
    override func bind() {
        
        options?.action
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] action in
                
                switch action {
                case let payload as OptionSelectorAction.OptionDidSelected:
                    
                    guard let selected = options?.selected, let bankType = BankType(rawValue: selected) else {
                        return
                    }
                    
                    switch bankType {
                    case .sfp:
                        let banksData = model.bankList.value.filter({$0.bankType == .sfp})
                        items = Self.reduceItems(bankList: banksData)
                        header.icon = .ic24SBP
                        
                    case .direct:
                        let banksData = model.bankList.value.filter({$0.bankType == .direct})
                        items = Self.reduceItems(bankList: banksData)
                        header.icon = .ic24Bank
                        
                    case .unknown: break
                    }
                    
                    if payload.optionId != "Российские" || payload.optionId != "Иностранные" {
                        
                        let banksData = model.bankList.value
                        items = banksData
                            .map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
                            .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
                            .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
                        
                        header.icon = .ic24Bank
                    }
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        $mode
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] mode in
                switch mode {
                case .search(let search):
                    
                    isCollapsed = true
                    
                    search.action
                        .receive(on: DispatchQueue.main)
                        .sink { action in
                            
                            switch action {
                            case _ as SearchBarViewModelAction.ChangeState:
                                
                                self.mode = .normal
                                
                            default: break
                            }
                            
                        }.store(in: &bindings)
                    
                    search.textFieldPhoneNumberView.$text
                        .receive(on: DispatchQueue.main)
                        .sink { text in
                            
                            if let text = text {
                                
                                let filteredBanks = self.model.bankList.value.filter({ bank in
                                    if bank.memberNameRus.localizedStandardContains(text) {
                                        
                                        return true
                                    }
                                    return false
                                })
                                
                                self.items = filteredBanks
                                    .map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
                                    .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
                                    .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
                                
                            } else {
                                
                                //                                        section.options?.selected = section.options?.selected
                            }
                            
                        }.store(in: &bindings)
                    
                    
                default: break
                }
            }.store(in: &bindings)
    }
    
    enum Mode {
        
        case normal
        case search(SearchBarView.ViewModel)
    }
    
    static func createOptionViewModel() -> OptionSelectorView.ViewModel? {
        
        var options = BankType.valid.map { bankType in
            
            return Option(id: bankType.rawValue, name: bankType.name)
        }
        
        options.append(Option(id: "all", name: "Все"))
        
        guard let firstOption = options.first?.id else {
            return nil
        }
        
        let optionViewModel: OptionSelectorView.ViewModel = .init(options: options, selected: firstOption, style: .template, mode: .action)
        return optionViewModel
    }
    
    static func reduceBanks(banksData: [BankData], filterByType: BankType? = nil, filterByName: String? = nil) -> [CollapsableSectionViewModel.ItemViewModel] {
        
        var banks = [CollapsableSectionViewModel.ItemViewModel]()
        
        banks = banksData.map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
        banks = banks.sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
        banks = banks.sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
        
        if let filter = filterByType {
            
            banks = banks.filter({$0.bankType == filter})
        }
        
        if let filter = filterByName, filter != "" {
            banks = banks.filter({ bank in
                if bank.title.localizedStandardContains(filter) {
                    
                    return true
                }
                return false
            })
        }
        
        return banks
    }
    
    static func reduceItems(bankList: [BankData]) -> [CollapsableSectionViewModel.ItemViewModel] {
        
        var items = [CollapsableSectionViewModel.ItemViewModel]()
        
        items = bankList
            .map({CollapsableSectionViewModel.ItemViewModel(title: $0.memberNameRus, image: $0.svgImage.image, bankType: $0.bankType, action: {})})
            .sorted(by: {$0.title.lowercased() < $1.title.lowercased()})
            .sorted(by: {$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending})
        
        return items
    }
}
