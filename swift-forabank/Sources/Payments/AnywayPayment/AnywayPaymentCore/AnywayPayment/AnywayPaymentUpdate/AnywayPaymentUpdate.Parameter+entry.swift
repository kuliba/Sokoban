//
//  AnywayPaymentUpdate.Parameter+entry.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentDomain

public extension AnywayPaymentUpdate.Parameter {
    
    var entry: Entry? {
        
        switch uiAttributes.viewType {
        case .constant:
            switch uiAttributes.dataType {
            case .number, .string:
                return field.content.map { .nonEditable(.string($0)) }
                
            case let .pairs(pair, _):
                return .nonEditable(.pair(key: pair.key, value: pair.value))
            }
            
        case .input:
            switch uiAttributes.dataType {
            case .number:
                switch uiAttributes.type {
                case .input:
                    return .numberInput(id: field.id, value: field.content)
                    
                case .maskList, .select:
                    return nil
                }
                
            case let .pairs(pair, pairs):
                switch uiAttributes.type {
                case .input:
                    return nil
                    
                case .maskList:
                    return .maskList(pair, pairs)
                    
                case .select:
                    return .select(pair, pairs)
                }
                
            case .string:
                switch uiAttributes.type {
                case .input:
                    return .textInput(id: field.id, value: field.content)
                    
                case .maskList, .select:
                    return nil
                }
            }
            
        case .output:
            switch uiAttributes.dataType {
            case .number, .string:
                return field.content.map { .hidden($0) }
                
            case let .pairs(pair, _):
                return .hidden(pair.key)
            }
        }
    }
    
    enum Entry: Equatable {
        
        case hidden(String)
        case maskList(Pair, [Pair])
        case nonEditable(Field)
        case numberInput(id: ID, value: Value?)
        case select(Pair, [Pair])
        case textInput(id: ID, value: Value?)
    }
}

public extension AnywayPaymentUpdate.Parameter.Entry {
    
    enum Field: Equatable {
        
        case string(String)
        case pair(key: String, value: String)
    }
    
    typealias ID = String
    typealias Value = String
    
    typealias Pair = AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair
}
