//
//  PaymentsDataModel+Parameter.swift
//  ForaBank
//
//  Created by Max Gribov on 10.02.2022.
//

import Foundation

extension Payments.Parameter {
    
    enum Identifier: String {
        
        case category       = "ru.forabank.sense.category"
        case service        = "ru.forabank.sense.service"
        case `operator`     = "ru.forabank.sense.operator"
        case template       = "ru.forabank.sense.template"
        case card           = "ru.forabank.sense.card"
        case amount         = "ru.forabank.sense.amount"
        case final          = "ru.forabank.sense.final"
        case code           = "ru.forabank.sense.code"
        case mock           = "ru.forabank.sense.mock"
    }
    
    static let emptyMock = Payments.Parameter(id: Identifier.mock.rawValue, value: nil)
}

extension Payments {
    
    struct ParameterSelectService: ParameterRepresentable {
        
        let parameter: Parameter
        let category: Category
        let options: [Option]
        let editable: Bool = false
        let collapsable: Bool = false
        let affectsHistory: Bool = false
        
        internal init(value: String? = nil, category: Category, options: [Option]) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.category.rawValue, value: value)
            self.category = category
            self.options = options
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectService(value: value, category: category, options: options)
        }
        
        struct Option: Identifiable {
            
            var id: String { service.rawValue }
            let service: Service
            let title: String
            let description: String
            let icon: ImageData
        }
    }
    
    struct ParameterTemplate: ParameterRepresentable {
        
        let parameter: Parameter
        let editable: Bool = false
        let collapsable: Bool = false
        let affectsHistory: Bool = false
        var templateId: PaymentTemplateData.ID? {
            
            guard let value = parameter.value else {
                return nil
            }
            
            return PaymentTemplateData.ID(value)
        }
        
        internal init(templateId: PaymentTemplateData.ID) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.template.rawValue, value: String(templateId))
        }
    }
    
    struct ParameterOperator: ParameterRepresentable {
        
        let parameter: Parameter
        let editable: Bool = false
        let collapsable: Bool = false
        let affectsHistory: Bool = false
        var `operator`: Operator? {
            
            guard let value = parameter.value else {
                return nil
            }
            
            return Operator(rawValue: value)
        }
        
        internal init(operatorType: Operator) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.operator.rawValue, value: operatorType.rawValue)
        }
    }
    
    struct ParameterSelect: ParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let options: [Option]
        let editable: Bool
        let collapsable: Bool
        let affectsHistory: Bool
        
        internal init(_ parameter: Parameter, title: String, options: [Option], editable: Bool = true, collapsable: Bool = false, affectsHistory: Bool = false) {
            
            self.parameter = parameter
            self.title = title
            self.options = options
            self.editable = editable
            self.collapsable = collapsable
            self.affectsHistory = affectsHistory
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelect(.init(id: parameter.id, value: value), title: title, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(editable: Bool) -> ParameterRepresentable {
            
            ParameterSelect(parameter, title: title, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterSelect(parameter, title: title, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let icon: ImageData
        }
    }
    
    struct ParameterSelectSimple: ParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let selectionTitle: String
        let description: String?
        let options: [Option]
        let editable: Bool
        let collapsable: Bool
        let affectsHistory: Bool
        
        internal init(_ parameter: Parameter, icon: ImageData, title: String, selectionTitle: String, description: String? = nil, options: [Option], editable: Bool = true, collapsable: Bool = false, affectsHistory: Bool = false) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.selectionTitle = selectionTitle
            self.description = description
            self.options = options
            self.editable = editable
            self.collapsable = collapsable
            self.affectsHistory = affectsHistory
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectSimple(.init(id: parameter.id, value: value), icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(editable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSimple(parameter, icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSimple(parameter, icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
        }
    }
    
    struct ParameterSelectSwitch: ParameterRepresentable {
        
        let parameter: Parameter
        let options: [Option]
        let editable: Bool
        let collapsable: Bool
        let affectsHistory: Bool
        
        internal init(_ parameter: Parameter, options: [Option], editable: Bool = true, collapsable: Bool = false, affectsHistory: Bool = false) {
            
            self.parameter = parameter
            self.options = options
            self.editable = editable
            self.collapsable = collapsable
            self.affectsHistory = affectsHistory
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectSwitch(.init(id: parameter.id, value: value), options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(editable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSwitch(parameter, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSwitch(parameter, options: options, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
        }
    }
    
    struct ParameterInput: ParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let validator: Validator
        let editable: Bool
        let collapsable: Bool
        let affectsHistory: Bool
        
        internal init(_ parameter: Parameter, icon: ImageData, title: String, validator: Validator, editable: Bool = true, collapsable: Bool = false, affectsHistory: Bool = false) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.editable = editable
            self.collapsable = collapsable
            self.affectsHistory = affectsHistory
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterInput(.init(id: parameter.id, value: value), icon: icon, title: title, validator: validator,editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(editable: Bool) -> ParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, validator: validator, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, validator: validator, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        struct Validator: ValidatorProtocol {
            
            let minLength: Int
            let maxLength: Int?
            let regEx: String?
            
            func isValid(value: String) -> Bool {
                
                guard value.count >= minLength else {
                    return false
                }
                
                if let maxLength = maxLength {
                    
                    guard value.count <= maxLength else {
                        return false
                    }
                }
                
                if let regEx = regEx {
                    
                    let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
                    return predicate.evaluate(with: value)
                }
                
                return true
            }
        }
    }
    
    struct ParameterInfo: ParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let editable: Bool = false
        let collapsable: Bool
        let affectsHistory: Bool = false
        
        internal init(_ parameter: Parameter, icon: ImageData, title: String, collapsable: Bool = false) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterInfo(.init(id: parameter.id, value: value), icon: icon, title: title, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterInfo(parameter, icon: icon, title: title, collapsable: collapsable)
        }
    }
    
    struct ParameterName: ParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        let editable: Bool
        let collapsable: Bool
        let affectsHistory: Bool
        
        internal init(_ parameter: Parameter, title: String, lastName: Name, firstName: Name, middleName: Name, editable: Bool = true, collapsable: Bool = false, affectsHistory: Bool = false) {
            
            self.parameter = parameter
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.editable = editable
            self.collapsable = collapsable
            self.affectsHistory = affectsHistory
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterName(.init(id: parameter.id, value: value), title: title, lastName: lastName, firstName: firstName, middleName: middleName, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(editable: Bool) -> ParameterRepresentable {
            
            ParameterName(parameter, title: title, lastName: lastName, firstName: firstName, middleName: middleName, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterName(parameter, title: title, lastName: lastName, firstName: firstName, middleName: middleName, editable: editable, collapsable: collapsable, affectsHistory: affectsHistory)
        }
        
        struct Name {
            
            let title: String
            let value: String
        }
    }
    
    struct ParameterAmount: ParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let currency: Currency
        let validator: Validator
        let editable: Bool = true
        let collapsable: Bool = false
        let affectsHistory: Bool = false
        
        var amount: Double {
            //TODO: double from value
            return 0
        }

        internal init(_ parameter: Parameter, title: String, currency: Currency, validator: Validator) {
            
            self.parameter = parameter
            self.title = title
            self.currency = currency
            self.validator = validator
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterAmount(.init(id: parameter.id, value: value), title: title, currency: currency, validator: validator)
        }
        
        struct Validator: ValidatorProtocol {
            
            let minAmount: Double
            
            func isValid(value: Double) -> Bool {
                
                guard value >= minAmount else {
                    return false
                }
                
                return true
            }
        }
    }
    
    struct ParameterCard: ParameterRepresentable {
        
        let parameter: Parameter
        let editable: Bool = false
        let collapsable: Bool = false
        let affectsHistory: Bool = false
    
        internal init() {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.card.rawValue, value: nil)
        }
    }
    
    struct ParameterFinal: ParameterRepresentable {
        
        let parameter: Parameter
        let editable: Bool = false
        let collapsable: Bool = false
        let affectsHistory: Bool = false
    
        internal init() {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.final.rawValue, value: nil)
        }
    }
    
    struct ParameterMock: ParameterRepresentable {
        
        let parameter: Parameter
        let editable: Bool = false
        let collapsable: Bool = false
        let affectsHistory: Bool = false
    
        internal init() {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.mock.rawValue, value: nil)
        }
    }
}
