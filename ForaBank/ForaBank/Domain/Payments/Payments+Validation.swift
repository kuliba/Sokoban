//
//  Payments+Validation.swift
//  Vortex
//
//  Created by Max Gribov on 08.12.2022.
//

import Foundation

extension Payments {
    
    enum Validation {
        
        struct RulesSystem {
            
            let rules: [any PaymentsValidationRulesSystemRule]
            
            func evaluate(_ value: Payments.Parameter.Value) -> Bool {
                
                rules.map({ $0.grade(value) }).reduce(true) { partialResult, grade in
                    
                    partialResult && grade
                }
            }
            
            func action(with value: Payments.Parameter.Value, for stage: Stage) -> Action? {
                
                let grades: [(grade: Bool, action: Action?)] = rules.map({ ($0.grade(value), $0.actions[stage])} )
                guard let firstFailedRule = grades.first(where: { $0.grade == false }) else {
                    return nil
                }
                
                return firstFailedRule.action
            }
        }
        
        enum Stage {
            
            case input
            case post
        }
        
        enum Action: Equatable {
            
            case warning(String)
            case autoContinue
        }
    }
}

//MARK: - Validator Protocol

extension Payments.Validation.RulesSystem: ValidatorProtocol {
    
    func isValid(value: Payments.Parameter.Value) -> Bool {
        
        evaluate(value)
    }
    
    static let anyValue = Payments.Validation.RulesSystem(rules: [])
}

//MARK: - Rules

extension Payments.Validation {
    
    struct MinLengthRule: PaymentsValidationRulesSystemRule {
        
        let actions: [Payments.Validation.Stage : Payments.Validation.Action]
        let minLength: UInt
        
        init(minLenght: UInt, actions: [Stage: Action]) {
            
            self.minLength = minLenght
            self.actions = actions
        }
        
        func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            guard let value = value else {
                return false
            }
            
            return value.count >= minLength
        }
    }
    
    struct MaxLengthRule: PaymentsValidationRulesSystemRule {
        
        let actions: [Payments.Validation.Stage : Payments.Validation.Action]
        let maxLength: UInt
        
        init(maxLenght: UInt, actions: [Stage: Action]) {
            
            self.maxLength = maxLenght
            self.actions = actions
        }
        
        func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            guard let value = value else {
                return false
            }
            
            return value.count <= maxLength
        }
    }
    
    struct LengthLimitsRule: PaymentsValidationRulesSystemRule {
        
        let actions: [Payments.Validation.Stage : Payments.Validation.Action]
        let lengthLimits: Set<UInt>
        
        init(lengthLimits: Set<UInt>, actions: [Stage: Action]) {
            
            self.lengthLimits = lengthLimits
            self.actions = actions
        }
        
        func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            guard let value = value else {
                return false
            }
            
            return lengthLimits.map({ Int($0) }).contains(value.count)
        }
    }
    
    struct ContainsStringRule: PaymentsValidationRulesSystemRule {
        
        let actions: [Payments.Validation.Stage : Payments.Validation.Action]
        let start: UInt
        let expected: String
        
        init(start: UInt, expected: String, actions: [Stage: Action]) {
            
            self.start = start
            self.expected = expected
            self.actions = actions
        }
        
        func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            let minimumLength = Int(start) + expected.count
            guard let value = value, value.count >= minimumLength else {
                return false
            }
            
            let rangeStart = String.Index(utf16Offset: Int(start), in: value)
            let rangeEnd = String.Index(utf16Offset: minimumLength, in: value)
            let characterInRange = value[rangeStart..<rangeEnd]
            
            return characterInRange == expected
        }
    }
    
    struct RegExpRule: PaymentsValidationRulesSystemRule {
        
        let actions: [Payments.Validation.Stage : Payments.Validation.Action]
        let regExp: String
        
        init(regExp: String, actions: [Stage: Action]) {
            
            self.regExp = regExp
            self.actions = actions
        }
        
        func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            let predicate = NSPredicate(format:"SELF MATCHES %@", regExp)
            
            return predicate.evaluate(with: value)
        }
    }
    
    struct OptionalRegExpRule: PaymentsValidationRulesSystemRule {
        
        let actions: [Payments.Validation.Stage : Payments.Validation.Action]
        let regExp: String
        
        init(regExp: String, actions: [Stage: Action]) {
            
            self.regExp = regExp
            self.actions = actions
        }
        
        func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            if value == nil {
               return true
            }
            let predicateFirst = NSPredicate(format:"SELF MATCHES %@", regExp)
            
            return predicateFirst.evaluate(with: value)
        }
    }
}
