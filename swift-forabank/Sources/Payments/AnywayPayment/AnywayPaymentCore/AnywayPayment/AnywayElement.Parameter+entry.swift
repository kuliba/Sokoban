//
//  AnywayElement.Parameter+entry.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentDomain

public extension AnywayElement.Parameter {
    
    var entry: Entry? {
        
        switch uiAttributes.viewType {
        case .constant:
            switch uiAttributes.dataType {
            case ._backendReserved:
                return nil
                
            case .number, .string:
                return field.value.map { .nonEditable(.string($0.rawValue)) }
                
            case let .pairs(pair, _):
                return .nonEditable(.pair(key: pair.key, value: pair.value))
            }
            
        case .input:
            switch uiAttributes.dataType {
            case ._backendReserved:
                return nil
                
            case .number:
                switch uiAttributes.type {
                case .input:
                    return .numberInput(id: field.id, value: field.value)
                    
                case .maskList, .missing, .select:
                    return nil
                }
                
            case let .pairs(pair, pairs):
                switch uiAttributes.type {
                case .input, .missing:
                    return nil
                    
                case .maskList:
                    return .maskList(pair, pairs)
                    
                case .select:
                    return .select(pair, pairs)
                }
                
            case .string:
                switch uiAttributes.type {
                case .input:
                    return .textInput(id: field.id, value: field.value)
                    
                case .maskList, .missing, .select:
                    return nil
                }
            }
            
        case .output:
            switch uiAttributes.dataType {
            case ._backendReserved:
                return .hidden("OUTPUT")
                
            case .number, .string:
                return field.value.map { .hidden($0.rawValue) }
                
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

public extension AnywayElement.Parameter.Entry {
    
    enum Field: Equatable {
        
        case string(String)
        case pair(key: String, value: String)
    }
    
    typealias ID = AnywayElement.Parameter.Field.ID
    typealias Value = AnywayElement.Parameter.Field.Value
    
    typealias Pair = AnywayElement.Parameter.UIAttributes.DataType.Pair
}

