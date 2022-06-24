//
//  MainViewSectionViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine
import SwiftUI

class MainSectionViewModel: ObservableObject, Identifiable {

    let action: PassthroughSubject<Action, Never> = .init()
    
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

//MARK: - Types

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
    
    enum Products {
 
        struct ProductDidTapped: Action {
            
            let productId: ProductData.ID
        }
        
        struct ScrollToGroup: Action {
            
            let groupId: MainSectionProductsGroupView.ViewModel.ID
        }
        
        struct MoreButtonTapped: Action {}
        
        struct HorizontalOffsetDidChanged: Action {
            
            let offset: CGFloat
        }
    }
    
    enum OpenProduct {
    
        struct ButtonTapped: Action {
            
            let productType: ProductType
        }
    }
    
    enum FastPayment {
    
        struct ButtonTapped: Action {
            
            let operationType: MainSectionFastOperationView.ViewModel.FastOperations
        }
    }
    
    enum Atm {
    
        struct ButtonTapped: Action {}
    }
}
