//
//  TransfersSectionViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 24.11.2022.
//

import Combine

// MARK: - ViewModel

class TransfersSectionViewModel: Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    var id: String { type.rawValue }
    lazy var title: String = type.title
    
    var type: TransfersSectionType {
        fatalError("Must overloaded in subclasses")
    }
}

// MARK: - Types

enum TransfersSectionType: String, CaseIterable {
    
    case directions
    case cover
    case info
    case promo
    case countries
    case advantages
    case questions
    case support
    
    var title: String {
        
        switch self {
        case .directions: return "Популярные направления"
        case .cover: return ""
        case .info: return ""
        case .promo: return ""
        case .countries: return "Список стран"
        case .advantages: return "Преимущества"
        case .questions: return "Часто задаваемые вопросы"
        case .support: return "Онлайн поддержка"
        }
    }
}

// MARK: - Action

enum TransfersSectionAction {
    
    // Section Popular destinations
    
    enum Direction {
        
        enum Detail {
            
            enum Order {
                
                struct Tap: Action {}
            }
            
            enum Transfers {
                
                struct Tap: Action {}
            }
            
        }
        
        struct Tap: Action {
            
            let countryCode: String
        }
    }
}
