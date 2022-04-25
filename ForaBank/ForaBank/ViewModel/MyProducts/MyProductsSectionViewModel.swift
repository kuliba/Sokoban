//
//  MyProductsSectionViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.04.2022.
//

import Combine

class MyProductsSectionViewModel: ObservableObject, Identifiable {
    
    let type: SectionType
    let isEnabled: Bool
    
    @Published var isCollapsed: Bool
    @Published var items: [MyProductsSectionItemViewModel]
    
    var id: String { type.rawValue }
    var title: String { type.name }
    
    @Published var selectedItemID: String = .init()
    
    init(type: SectionType,
         items: [MyProductsSectionItemViewModel],
         isCollapsed: Bool,
         isEnabled: Bool) {
        
        self.type = type
        self.isCollapsed = isCollapsed
        self.isEnabled = isEnabled
        self.items = items
    }
    
    enum SectionType: String, CaseIterable {
        
        case inactiveProducts
        case cards
        case deposits
        case credits
        case investment
        case insurance
        
        var name: String {
            
            switch self {
            case .inactiveProducts: return "Неактивированные продукты"
            case .cards: return "Карты"
            case .deposits: return "Вклады"
            case .credits: return "Кредиты"
            case .investment: return "Инвестиции"
            case .insurance: return "Страховка"
            }
        }
    }
}

extension MyProductsSectionViewModel {
    
    static let sample1 = MyProductsSectionViewModel(
        type: .inactiveProducts,
        items: [.sample1, .sample2, .sample3],
        isCollapsed: false,
        isEnabled: true
    )
    
    static let sample2 = MyProductsSectionViewModel(
        type: .cards,
        items: [.sample4, .sample5],
        isCollapsed: false,
        isEnabled: true
    )
    
    static let sample3 = MyProductsSectionViewModel(
        type: .deposits,
        items: [.sample6],
        isCollapsed: true,
        isEnabled: true
    )
    
    static let sample4 = MyProductsSectionViewModel(
        type: .credits,
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
    
    static let sample5 = MyProductsSectionViewModel(
        type: .investment,
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
    
    static let sample6 = MyProductsSectionViewModel(
        type: .insurance,
        items: [],
        isCollapsed: false,
        isEnabled: false
    )
}
