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
        case mock           = "ru.forabank.sense.mock"
        case final          = "ru.forabank.sense.final"
    }
    
    static let emptyMock = Payments.Parameter(id: Identifier.mock.rawValue, value: nil)
}

extension Payments {
    
    struct ParameterSelectService: ParameterRepresentable {
        
        let parameter: Parameter
        let category: Category
        let options: [Option]
        let collapsable: Bool
        
        internal init(value: String? = nil, category: Category, options: [Option], collapsable: Bool = false) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.category.rawValue, value: value)
            self.category = category
            self.options = options
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectService(value: value, category: category, options: options, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterSelectService(value: parameter.value, category: category, options: options, collapsable: collapsable)
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
        let collapsable: Bool
        var templateId: PaymentTemplateData.ID? {
            
            guard let value = parameter.value else {
                return nil
            }
            
            return PaymentTemplateData.ID(value)
        }
        
        internal init(templateId: PaymentTemplateData.ID) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.template.rawValue, value: String(templateId))
            self.collapsable = false
        }
        
        internal init(value: String?) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.template.rawValue, value: value)
            self.collapsable = false
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterTemplate(value: value)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            self
        }
    }
    
    struct ParameterOperator: ParameterRepresentable {
        
        let parameter: Parameter
        let collapsable: Bool
        var `operator`: Operator? {
            
            guard let value = parameter.value else {
                return nil
            }
            
            return Operator(rawValue: value)
        }
        
        internal init(operatorType: Operator) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.operator.rawValue, value: operatorType.rawValue)
            self.collapsable = false
        }
        
        internal init(value: String?) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.operator.rawValue, value: value)
            self.collapsable = false
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterOperator(value: value)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            self
        }
    }
    
    struct ParameterSelect: ParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let options: [Option]
        let collapsable: Bool
        
        internal init(_ parameter: Parameter, title: String, options: [Option], collapsable: Bool = false) {
            
            self.parameter = parameter
            self.title = title
            self.options = options
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelect(.init(id: parameter.id, value: value), title: title, options: options, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterSelect(parameter, title: title, options: options, collapsable: collapsable)
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
        let collapsable: Bool
        
        internal init(_ parameter: Parameter, icon: ImageData, title: String, selectionTitle: String, description: String? = nil, options: [Option], collapsable: Bool = false) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.selectionTitle = selectionTitle
            self.description = description
            self.options = options
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectSimple(.init(id: parameter.id, value: value), icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSimple(parameter, icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, collapsable: collapsable)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
        }
    }
    
    struct ParameterSelectSwitch: ParameterRepresentable {
        
        let parameter: Parameter
        let options: [Option]
        let collapsable: Bool
        
        internal init(_ parameter: Parameter, options: [Option], collapsable: Bool = false) {
            
            self.parameter = parameter
            self.options = options
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectSwitch(.init(id: parameter.id, value: value), options: options, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSwitch(parameter, options: options, collapsable: collapsable)
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
        let collapsable: Bool
        
        internal init(_ parameter: Parameter, icon: ImageData, title: String, validator: Validator, collapsable: Bool = false) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterInput(.init(id: parameter.id, value: value), icon: icon, title: title, validator: validator, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, validator: validator, collapsable: collapsable)
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
        let content: String
        let collapsable: Bool
        
        internal init(_ parameter: Parameter, icon: ImageData, title: String, content: String, collapsable: Bool = false) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.content = content
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterInfo(.init(id: parameter.id, value: value), icon: icon, title: title, content: content, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterInfo(parameter, icon: icon, title: title, content: content, collapsable: collapsable)
        }
    }
    
    struct ParameterName: ParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        let collapsable: Bool
        
        internal init(_ parameter: Parameter, title: String, lastName: Name, firstName: Name, middleName: Name, collapsable: Bool = false) {
            
            self.parameter = parameter
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterName(.init(id: parameter.id, value: value), title: title, lastName: lastName, firstName: firstName, middleName: middleName, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterName(parameter, title: title, lastName: lastName, firstName: firstName, middleName: middleName, collapsable: collapsable)
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
        var amount: Double {
            //TODO: double from value
            return 0
        }
        let collapsable: Bool
        
        internal init(_ parameter: Parameter, title: String, currency: Currency, validator: Validator, collapsable: Bool = false) {
            
            self.parameter = parameter
            self.title = title
            self.currency = currency
            self.validator = validator
            self.collapsable = collapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterAmount(.init(id: parameter.id, value: value), title: title, currency: currency, validator: validator, collapsable: collapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterAmount(parameter, title: title, currency: currency, validator: validator, collapsable: collapsable)
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
    
    struct ParameterFinal: ParameterRepresentable {
        
        let parameter: Parameter
        let collapsable: Bool
    
        internal init() {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.mock.rawValue, value: nil)
            self.collapsable = false
        }
     
        func updated(value: String?) -> ParameterRepresentable { self }
        func updated(collapsable: Bool) -> ParameterRepresentable { self }
    }
    
    struct ParameterMock: ParameterRepresentable {
        
        let parameter: Parameter
        let collapsable: Bool
    
        internal init() {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.mock.rawValue, value: nil)
            self.collapsable = false
        }
     
        func updated(value: String?) -> ParameterRepresentable { self }
        func updated(collapsable: Bool) -> ParameterRepresentable { self }
    }
}
