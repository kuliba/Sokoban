//
//  MainViewSectionViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine
import SwiftUI
import Banners

final class BannerPickerSectionBinderWrapper: MainSectionViewModel {
    override var type: MainSectionType { .promo }
    
    let binder: BannersBinder
    
    init(binder: BannersBinder) {
        self.binder = binder
    }
}

class MainSectionViewModel: Identifiable {

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
    
    case updateInfo
    case products
    case fastOperations
    case promo
    case currencyExchange
    case currencyMetall
    case openProduct
    case atm
    
    var name: String {
        
        switch self {
        case .updateInfo: return ""
        case .products: return "Мои продукты"
        case .fastOperations: return "Быстрые операции"
        case .promo: return ""
        case .currencyExchange: return "Обмен валют"
        case .currencyMetall: return "Обмен валюты"
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
        
        struct StickerDidTapped: Action {}
        
        struct ResetScroll: Action {}
        
        struct MoreButtonTapped: Action {}
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
    
    enum CurrencyMetall {
 
        enum DidTapped  {
            
            struct Item: Action {
                
                let code: Currency
            }
            
            struct Buy: Action {
                
                let code: Currency
            }
            
            struct Sell: Action  {
                
                let code: Currency
            }
        }
    }
    
    enum PromoAction {

        struct ButtonTapped: Action {
            
            let actionData: BannerAction
        }
    }
    
}
