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
            case .none, ._backendReserved:
                return nil
                
            case .integer, .number, .numeric, .string, .string2, .string2Rus, .stringEn:
                return field.content.map { .nonEditable(.string($0)) }
                
            case let .pairs(pair, pairs):
                return (pair ?? pairs.first).map {
                    
                    .nonEditable(.pair(key: $0.key, value: $0.value))
                }
            }
            
        case .input:
            switch uiAttributes.dataType {
            case .none, ._backendReserved:
                return nil
                
            case .integer, .number, .numeric:
                switch uiAttributes.type {
                case .input:
                    return .numberInput(id: field.id, value: field.content)
                    
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
                
            case .string, .string2, .string2Rus, .stringEn:
                switch uiAttributes.type {
                case .input:
                    return .textInput(id: field.id, value: field.content)
                    
                case .maskList, .missing, .select:
                    return nil
                }
            }
            
        case .output:
            switch uiAttributes.dataType {
            case .none:
                return nil
                
            case ._backendReserved:
                return .hidden("OUTPUT")
                
            case .integer, .number, .numeric, .string, .string2, .string2Rus, .stringEn:
                return field.content.map { .hidden($0) }
                
            case let .pairs(pair, pairs):
                return (pair ?? pairs.first).map { .hidden($0.key) }
            }
        }
    }
    
    enum Entry: Equatable {
        
        case hidden(String)
        case maskList(Pair?, [Pair])
        case nonEditable(Field)
        case numberInput(id: ID, value: Value?)
        case select(Pair?, [Pair])
        case textInput(id: ID, value: Value?)
    }
}

public extension AnywayPaymentUpdate.Parameter.Entry {
    
    enum Field: Equatable {
        
        case string(String)
        case pair(key: String?, value: String)
    }
    
    typealias ID = String
    typealias Value = String
    
    typealias Pair = AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair
}
