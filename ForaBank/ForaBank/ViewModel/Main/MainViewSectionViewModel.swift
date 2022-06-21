//
//  MainViewSectionViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine

class MainSectionViewModel: ObservableObject, Identifiable {

    let action: PassthroughSubject<Action, Never> = .init()
    
    var id: String { type.rawValue }
    var type: MainSectionType { fatalError("Implement in subclass")}
}

class MainSectionCollapsableViewModel: MainSectionViewModel {
    
    var title: String { type.name }
    @Published var isCollapsed: Bool
    
    init(isCollapsed: Bool) {
        
        self.isCollapsed = isCollapsed
        super.init()
    }
}

enum MainSectionType: String, CaseIterable, Codable {
    
    case products
    case fastOperations
    case promo
    case currencyExchange
    case openProduct
    case atm
    
    var name: String {
        
        switch self {
        case .products: return "Мои продукты"
        case .fastOperations: return "Быстрые операции"
        case .promo: return ""
        case .currencyExchange: return "Обмен валют"
        case .openProduct: return "Открыть продукт"
        case .atm: return "Отделения и банкоматы"
        }
    }
}

//MARK: - Action

enum MainSectionViewModelAction {

    enum OpenProduct {

        struct ButtonTapped: Action {

            let productType: ProductType
        }
    }
}
