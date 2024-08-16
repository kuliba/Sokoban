//
//  UIItem.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public enum UIItem<Latest> {
    
    case placeholder(UUID)
    case selectable(Selectable)
}

public extension UIItem {
    
    enum Selectable {
        
        case exchange
        case latest(Latest)
        case templates
    }
}

extension UIItem: Equatable where Latest: Equatable {}
extension UIItem.Selectable: Equatable where Latest: Equatable {}

extension UIItem: Identifiable where Latest: Identifiable {

    public var id: ID {

        switch self {
        case let .placeholder(uuid):
            return .placeholder(uuid)

        case let .selectable(selectable):
            switch selectable {
            case .exchange:
                return .exchange

            case let .latest(latest):
                return .latest(latest.id)

            case .templates:
                return .templates
            }
        }
    }

    public enum ID: Hashable {

        case exchange
        case latest(Latest.ID)
        case placeholder(UUID)
        case templates
    }
}

