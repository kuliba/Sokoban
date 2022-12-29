//
//  Payments+Validation.swift
//  ForaBank
//
//  Created by Max Gribov on 08.12.2022.
//

import Foundation

extension Payments {
    
    enum Validation {
        
        struct RulesSystem {
            
            let rules: [Rule]
            
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

        class Rule {
            
            let actions: [Stage: Action]
            
            init(actions: [Stage: Action]) {
                
                self.actions = actions
            }
            
            func grade(_ value: Payments.Parameter.Value) -> Bool {
                
                fatalError("Implement in subclass")
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
    
    class MinLengthRule: Rule {
        
        let minLength: UInt
        
        init(minLenght: UInt, actions: [Stage: Action]) {
            
            self.minLength = minLenght
            super.init(actions: actions)
        }
        
        override func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            guard let value = value else {
                return false
            }
            
            return value.count >= minLength
        }
    }
    
    class MaxLengthRule: Rule {
        
        let maxLength: UInt
        
        init(maxLenght: UInt, actions: [Stage: Action]) {
            
            self.maxLength = maxLenght
            super.init(actions: actions)
        }
        
        override func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            guard let value = value else {
                return false
            }
            
            return value.count <= maxLength
        }
    }
    
    class LengthLimitsRule: Rule {
        
        let lengthLimits: Set<UInt>
        
        init(lengthLimits: Set<UInt>, actions: [Stage: Action]) {
            
            self.lengthLimits = lengthLimits
            super.init(actions: actions)
        }
        
        override func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            guard let value = value else {
                return false
            }
            
            return lengthLimits.map({ Int($0) }).contains(value.count)
        }
    }
    
    class ContainsStringRule: Rule {
        
        let start: UInt
        let expected: String
        
        init(start: UInt, expected: String, actions: [Stage: Action]) {
            
            self.start = start
            self.expected = expected
            super.init(actions: actions)
        }
        
        override func grade(_ value: Payments.Parameter.Value) -> Bool {
            
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
    
    class RegExpRule: Rule {
        
        let regExp: String
        
        init(regExp: String, actions: [Stage: Action]) {
            
            self.regExp = regExp
            super.init(actions: actions)
        }
        
        override func grade(_ value: Payments.Parameter.Value) -> Bool {
            
            let predicate = NSPredicate(format:"SELF MATCHES %@", regExp)
            
            return predicate.evaluate(with: value)
        }
    }
}
