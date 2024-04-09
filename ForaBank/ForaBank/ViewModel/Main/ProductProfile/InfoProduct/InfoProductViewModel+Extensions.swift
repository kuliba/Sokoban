//
//  InfoProductViewModel+Extensions.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 19.06.2023.
//

import Foundation
import SwiftUI
import AccountInfoPanel

extension InfoProductViewModel {
    
    struct DocumentItemModel {
        
        let id: ID
        
        enum ID {
            
            case accountNumber
            case bic
            case corrAccount
            case inn
            case kpp
            case payeeName
            case holderName
            case numberMasked
            case expirationDate
            case number
            case cvvMasked
            case cvv
            case cvvDisable
        }
        
        var title: String {
            
            switch id {
                
            case .accountNumber:
                return "Номер счета"
            case .bic:
                return "БИК"
            case .corrAccount:
                return "Корреспондентский счет"
            case .inn:
                return "ИНН"
            case .kpp:
                return "КПП"
            case .payeeName:
                return "Получатель"
            case .numberMasked, .number:
                return "Номер карты"
            case .holderName:
                return "Держатель карты"
            case .expirationDate:
                return "Карта действует до"
            case .cvvMasked, .cvv, .cvvDisable:
                return .cvvTitle
            }
        }
        
        var titleForInformer: String {
            switch id {
                
            case .expirationDate:
                return "Срок действия карты"
                
            default:
                return title
            }
        }
        
        let subtitle: String
        let valueForCopy: String
    }
    
    struct ItemViewModelWithAction: Equatable, Hashable {
        
        static func == (lhs: InfoProductViewModel.ItemViewModelWithAction, rhs: InfoProductViewModel.ItemViewModelWithAction) -> Bool {
            
            lhs.id == rhs.id && lhs.subtitle == rhs.subtitle
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(subtitle)
        }
        
        let id: DocumentItemModel.ID
        let title: String
        let titleForInformer: String
        var subtitle: String
        let valueForCopy: String
        let actionForLongPress: (String, String) -> Void
        let actionForIcon: () -> Void
        
        var icon: Image? {
            
            return Dictionary.allIcons[id]
        }
    }
    
    enum ItemViewModelForList: Hashable {
        
        func hash(into hasher: inout Hasher) {
            
            switch self {
            case let .single(item):
                hasher.combine(item)
            case let .multiple(items):
                hasher.combine(items)
            }
        }
        
        case single(ItemViewModelWithAction)
        case multiple([ItemViewModelWithAction])
        
        var currentValues: [ItemViewModelWithAction] {
            
            switch self {
            case let .single(item):
                
                return [item]
                
            case let .multiple(items):
                
                return items
            }
        }
        
        var currentValueString: String {
            
            self.currentValues.compactMap {
                
                switch $0.id {
                    
                case .cvv, .cvvMasked, .cvvDisable:
                    return nil
                    
                default:
                    return $0.title + ": " + $0.valueForCopy
                }
            }.joined(separator: "\n")
        }
        
        var isAccountHolder: Bool {
            
            (self.currentValues.first {
                
                if $0.id == .accountNumber {
                    return !$0.subtitle.isEmpty
                }
                return false
            } != nil)
        }
    }
}

extension InfoProductViewModel {
    
    static func reduceSingle(
        data: AccountInfoPanel.ProductDetails
    ) -> [DocumentItemModel] {
        
        return [
            .init(
                id: .payeeName,
                subtitle: data.payeeName,
                valueForCopy: data.payeeName
            ),
            .init(
                id: .accountNumber,
                subtitle: data.accountNumber,
                valueForCopy: data.accountNumber
            ),
            .init(
                id: .bic,
                subtitle: data.bic,
                valueForCopy: data.bic
            ),
            .init(
                id: .corrAccount,
                subtitle: data.corrAccount,
                valueForCopy: data.corrAccount
            )
        ]
    }
    
    static func reduceMultiple(
        data: AccountInfoPanel.ProductDetails
    ) -> [DocumentItemModel] {
        
        return [
            .init(
                id: .inn,
                subtitle: data.inn,
                valueForCopy: data.inn
            ),
            .init(
                id: .kpp,
                subtitle: data.kpp,
                valueForCopy: data.kpp
            )
        ]
    }
    
    static func makeItemViewModel(
        from item: DocumentItemModel,
        with action: @escaping (String, String) -> Void
    ) -> ItemViewModelWithAction {
        
        return .init(
            id: item.id,
            title: item.title,
            titleForInformer: item.titleForInformer,
            subtitle: item.subtitle,
            valueForCopy: item.valueForCopy,
            actionForLongPress: action,
            actionForIcon: {}
        )
    }

    static func makeItemViewModel(
        from item: DocumentItemModel,
        with action: @escaping (String, String) -> Void,
        actionForIcon: @escaping () -> Void
    ) -> ItemViewModelWithAction {
        
        return .init(
            id: item.id,
            title: item.title,
            titleForInformer: item.titleForInformer,
            subtitle: item.subtitle,
            valueForCopy: item.valueForCopy,
            actionForLongPress: action,
            actionForIcon: actionForIcon
        )
    }
    
    static func makeItemViewModelSingle(
        from item: DocumentItemModel,
        with action: @escaping (String, String) -> Void
    ) -> ItemViewModelForList {
        
        return .single(
            makeItemViewModel(
                from: item,
                with: action
            )
        )
    }

    static func makeItemViewModelSingle(
        from item: DocumentItemModel,
        with action: @escaping (String, String) -> Void,
        actionForIcon: @escaping () -> Void
    ) -> ItemViewModelForList {
        
        return .single(
            makeItemViewModel(
                from: item,
                with: action,
                actionForIcon: actionForIcon
            )
        )
    }
    
    static func makeItemViewModelMultiple(
        from items: [DocumentItemModel],
        with action: @escaping (String, String) -> Void
    ) -> ItemViewModelForList {
        
        return .multiple(items.map {
            makeItemViewModel(
                from: $0,
                with: action
            )
        })
    }
}

//MARK: - card info

extension InfoProductViewModel {
    
    static func reduceSingle(
        data: ProductCardData,
        needShowFullNumber: Bool
    ) -> [DocumentItemModel] {
        
        var list: [DocumentItemModel] = []
        
        if let holderName = data.holderName {
            
            list.append(
                .init(
                    id: .holderName,
                    subtitle: holderName,
                    valueForCopy: holderName
                )
            )
        }
        
        if needShowFullNumber {
            
            if let number = data.number {
                
                list.append(
                    .init(
                        id: .number,
                        subtitle: number.formatted(),
                        valueForCopy: number.formatted()
                    )
                )
            }
        } else {
            
            if let numberMask = data.numberMasked,
               let number = data.number {
                
                list.append(
                    .init(
                        id: .numberMasked,
                        subtitle: numberMask,
                        valueForCopy: number.formatted()
                    )
                )
            }
        }
        
        return list
    }
    
    static func reduceMultiple(
        data: ProductCardData,
        needShowCvv: Bool
    ) -> [DocumentItemModel] {
        
        var list: [DocumentItemModel] = []
        
        data.expireDate.map {
            
            list.append(
                .init(
                    id: .expirationDate,
                    subtitle: $0,
                    valueForCopy: $0
                )
            )
        }
        if data.cardType == .additionalOther {
            
            list.append(
                .init(
                    id: .cvvDisable,
                    subtitle: "Недоступно",
                    valueForCopy: "" // CVV не копируем!!!
                )
            )
        } else {
            
            list.append(
                .init(
                    id: needShowCvv ? .cvv : .cvvMasked,
                    subtitle: "***",
                    valueForCopy: "" // CVV не копируем!!!
                )
            )
        }
        return list
    }
}

//MARK: - button info

extension InfoProductViewModel {
    
    struct ButtonModel {
        
        let id: ID
        
        enum ID {
            
            case sendSelected
            case sendAll
        }
        
        var title: String {
            
            switch id {
                
            case .sendSelected:
                return "Отправить выбранные"
            case .sendAll:
                return "Отправить все"
            }
        }
        
        let action: () -> Void
    }
}

//MARK: - DSL

typealias DocumentItemModel = InfoProductViewModel.DocumentItemModel

extension Dictionary where Key == DocumentItemModel.ID, Value == Image {
    
    static let allIcons: Self = [
        .numberMasked : .ic24Eye,
        .cvvMasked : .ic24Eye,
        .number: .ic24EyeOff,
        .cvv : .ic24EyeOff,
        .cvvDisable: .ic24Info
    ]
}

extension Array where Element == InfoProductViewModel.ItemViewModelForList {
    
    var isAccountHolder: Bool {
        
        (self.first(where: { $0.isAccountHolder }) != nil)
    }
}
