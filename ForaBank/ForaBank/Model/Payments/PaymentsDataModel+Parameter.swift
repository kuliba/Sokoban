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
        case product        = "ru.forabank.sense.product"
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
        var templateId: PaymentTemplateData.ID? {
            
            guard let value = parameter.value else {
                return nil
            }
            
            return PaymentTemplateData.ID(value)
        }
        
        init(templateId: PaymentTemplateData.ID) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.template.rawValue, value: String(templateId))
        }
    }
    
    struct ParameterOperator: ParameterRepresentable {
        
        let parameter: Parameter
        var `operator`: Operator? {
            
            guard let value = parameter.value else {
                return nil
            }
            
            return Operator(rawValue: value)
        }
        
        init(operatorType: Operator) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.operator.rawValue, value: operatorType.rawValue)
        }
    }
    
    struct ParameterSelect: ParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let options: [Option]
        let isEditable: Bool
        let isCollapsable: Bool
        let affectsHistory: Bool
        let isAutoContinue: Bool
        let processStep: Int?
        
        init(_ parameter: Parameter, title: String, options: [Option], isEditable: Bool = true, isCollapsable: Bool = false, affectsHistory: Bool = false, isAutoContinue: Bool = true, processStep: Int? = nil) {
            
            self.parameter = parameter
            self.title = title
            self.options = options
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.affectsHistory = affectsHistory
            self.isAutoContinue = isAutoContinue
            self.processStep = processStep
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelect(.init(id: parameter.id, value: value), title: title, options: options, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, isAutoContinue: isAutoContinue, processStep: processStep)
        }
        
        func updated(isEditable: Bool) -> ParameterRepresentable {
            
            ParameterSelect(parameter, title: title, options: options, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, isAutoContinue: isAutoContinue, processStep: processStep)
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
        let isEditable: Bool
        let isCollapsable: Bool
        let affectsHistory: Bool
        let isAutoContinue: Bool
        let processStep: Int?
        
        init(_ parameter: Parameter, icon: ImageData, title: String, selectionTitle: String, description: String? = nil, options: [Option], isEditable: Bool = true, isCollapsable: Bool = false, affectsHistory: Bool = false, isAutoContinue: Bool = true, processStep: Int? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.selectionTitle = selectionTitle
            self.description = description
            self.options = options
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.affectsHistory = affectsHistory
            self.isAutoContinue = isAutoContinue
            self.processStep = processStep
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectSimple(.init(id: parameter.id, value: value), icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, isAutoContinue: isAutoContinue, processStep: processStep)
        }
        
        func updated(isEditable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSimple(parameter, icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, isAutoContinue: isAutoContinue, processStep: processStep)
        }
    }
    
    struct ParameterSelectSwitch: ParameterRepresentable {
        
        let parameter: Parameter
        let options: [Option]
        let isEditable: Bool
        let isCollapsable: Bool
        let affectsHistory: Bool
        let isAutoContinue: Bool
        let processStep: Int?
        
        init(_ parameter: Parameter, options: [Option], isEditable: Bool = true, isCollapsable: Bool = false, affectsHistory: Bool = false, isAutoContinue: Bool = true, processStep: Int? = nil) {
            
            self.parameter = parameter
            self.options = options
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.affectsHistory = affectsHistory
            self.isAutoContinue = isAutoContinue
            self.processStep = processStep
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterSelectSwitch(.init(id: parameter.id, value: value), options: options, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, isAutoContinue: isAutoContinue, processStep: processStep)
        }
        
        func updated(isEditable: Bool) -> ParameterRepresentable {
            
            ParameterSelectSwitch(parameter, options: options, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, isAutoContinue: isAutoContinue, processStep: processStep)
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
        let isEditable: Bool
        let isCollapsable: Bool
        let affectsHistory: Bool
        let processStep: Int?
        
        init(_ parameter: Parameter, icon: ImageData, title: String, validator: Validator, isEditable: Bool = true, isCollapsable: Bool = false, affectsHistory: Bool = false, processStep: Int? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.affectsHistory = affectsHistory
            self.processStep = processStep
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterInput(.init(id: parameter.id, value: value), icon: icon, title: title, validator: validator,isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, processStep: processStep)
        }
        
        func updated(isEditable: Bool) -> ParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, validator: validator, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory, processStep: processStep)
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
        let isCollapsable: Bool
        
        init(_ parameter: Parameter, icon: ImageData, title: String, isCollapsable: Bool = false) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.isCollapsable = isCollapsable
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterInfo(.init(id: parameter.id, value: value), icon: icon, title: title, isCollapsable: isCollapsable)
        }
        
        func updated(collapsable: Bool) -> ParameterRepresentable {
            
            ParameterInfo(parameter, icon: icon, title: title, isCollapsable: collapsable)
        }
    }
    
    struct ParameterName: ParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        let isEditable: Bool
        let isCollapsable: Bool
        let affectsHistory: Bool
        let processStep: Int?
        
        init(_ parameter: Parameter, title: String, lastName: Name, firstName: Name, middleName: Name, isEditable: Bool = true, isCollapsable: Bool = false, affectsHistory: Bool = false, processStep: Int? = nil) {
            
            self.parameter = parameter
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.affectsHistory = affectsHistory
            self.processStep = processStep
        }
        
        init(id: Parameter.ID, value: String?, title: String, editable: Bool = true, collapsable: Bool = false, affectsHistory: Bool = false, processStep: Int? = nil) {
            
            self.init(.init(id: id, value: value), title: title, lastName: .init(title: "Фамилия", value: name(with: value, index: 0)), firstName: .init(title: "Имя", value: name(with: value, index: 1)), middleName: .init(title: "Отчество", value: name(with: value, index: 2)), isEditable: editable, isCollapsable: collapsable, affectsHistory: affectsHistory, processStep: processStep)
            
            func name(with value: String?, index: Int) -> String {
                
                guard let value = value else {
                    return ""
                }
                
                let valueSplitted = value.split(separator: " ")
                switch index {
                case 0:
                    guard valueSplitted.count > 0 else {
                        return ""
                    }
                    return String(valueSplitted[0])
                    
                case 1:
                    guard valueSplitted.count > 1 else {
                        return ""
                    }
                    return String(valueSplitted[1])
                    
                case 2:
                    guard valueSplitted.count > 2 else {
                        return ""
                    }
                    return String(valueSplitted[2])
                    
                default:
                    return ""
                }
            }
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterName(.init(id: parameter.id, value: value), title: title, lastName: lastName, firstName: firstName, middleName: middleName, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory)
        }
        
        func updated(isEditable: Bool) -> ParameterRepresentable {
            
            ParameterName(parameter, title: title, lastName: lastName, firstName: firstName, middleName: middleName, isEditable: isEditable, isCollapsable: isCollapsable, affectsHistory: affectsHistory)
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
 
            guard let value = parameter.value, let amount = Double(value) else {
                return 0
            }
            
            return amount
        }

        init(_ parameter: Parameter, title: String, currency: Currency, validator: Validator) {
            
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
            let maxAmount: Double
            
            func isValid(value: Double) -> Bool {
                
                //FIXME: implement correct floats comparision
                guard value >= minAmount, value <= maxAmount else {
                    return false
                }
                
                return true
            }
        }
    }
    
    struct ParameterProduct: ParameterRepresentable {
        
        let parameter: Parameter
        let isEditable: Bool
        let isHidden: Bool
        let affectsParameters: Bool = true
        
        init(_ parameter: Parameter, isEditable: Bool, isHidden: Bool) {
            
            self.parameter = parameter
            self.isEditable = isEditable
            self.isHidden = isHidden
        }
        
        init(value: String? = nil, isEditable: Bool = true, isHidden: Bool = true) {
            
            self.init(Parameter(id: Payments.Parameter.Identifier.product.rawValue, value: value), isEditable: isEditable, isHidden: isHidden)
        }
        
        func updated(value: String?) -> ParameterRepresentable {
            
            ParameterProduct(value: value, isEditable: isEditable, isHidden: isHidden)
        }
        
        func updated(isEditable: Bool) -> ParameterRepresentable {
            
            ParameterProduct(parameter, isEditable: isEditable, isHidden: isHidden)
        }
        
        func updated(isHidden: Bool) -> ParameterRepresentable {
            
            ParameterProduct(parameter, isEditable: isEditable, isHidden: isHidden)
        }
    }
    
    struct ParameterFinal: ParameterRepresentable {
        
        let parameter: Parameter

        internal init() {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.final.rawValue, value: nil)
        }
    }
    
    struct ParameterMock: ParameterRepresentable {
        
        let parameter: Parameter
        let processStep: Int?

        internal init(id: Payments.Parameter.ID = Payments.Parameter.Identifier.mock.rawValue, value: Payments.Parameter.Value = nil, processStep: Int? = nil) {
            
            self.parameter = Parameter(id: id, value: value)
            self.processStep = processStep
        }
    }
}
