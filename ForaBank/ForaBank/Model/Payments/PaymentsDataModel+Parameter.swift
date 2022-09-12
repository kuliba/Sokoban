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
    
    struct ParameterSelectService: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let category: Category
        let options: [Option]
        
        internal init(value: String? = nil, category: Category, options: [Option]) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.category.rawValue, value: value)
            self.category = category
            self.options = options
        }
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
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
    
    struct ParameterTemplate: PaymentsParameterRepresentable {
        
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
    
    struct ParameterOperator: PaymentsParameterRepresentable {
        
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
    
    struct ParameterSelect: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let options: [Option]
        let isEditable: Bool
        let isCollapsable: Bool
        let onChange: Payments.ParameterOnChangeAction
        let process: Payments.ParameterProcessType
        
        init(_ parameter: Parameter, title: String, options: [Option], isEditable: Bool = true, isCollapsable: Bool = false, onChange: Payments.ParameterOnChangeAction = .autoContinue, process: Payments.ParameterProcessType = .none) {
            
            self.parameter = parameter
            self.title = title
            self.options = options
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.onChange = onChange
            self.process = process
        }
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
            ParameterSelect(.init(id: parameter.id, value: value), title: title, options: options, isEditable: isEditable, isCollapsable: isCollapsable, onChange: onChange, process: process)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterSelect(parameter, title: title, options: options, isEditable: isEditable, isCollapsable: isCollapsable, onChange: onChange, process: process)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let icon: ImageData
        }
    }
    
    struct ParameterSelectSimple: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let selectionTitle: String
        let description: String?
        let options: [Option]
        let isEditable: Bool
        let isCollapsable: Bool
        let onChange: Payments.ParameterOnChangeAction
        let process: Payments.ParameterProcessType
        
        init(_ parameter: Parameter, icon: ImageData, title: String, selectionTitle: String, description: String? = nil, options: [Option], isEditable: Bool = true, isCollapsable: Bool = false, onChange: Payments.ParameterOnChangeAction = .autoContinue, process: Payments.ParameterProcessType = .none) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.selectionTitle = selectionTitle
            self.description = description
            self.options = options
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.onChange = onChange
            self.process = process
        }
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
            ParameterSelectSimple(.init(id: parameter.id, value: value), icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, isEditable: isEditable, isCollapsable: isCollapsable, onChange: onChange, process: process)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterSelectSimple(parameter, icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, isEditable: isEditable, isCollapsable: isCollapsable, onChange: onChange, process: process)
        }
    }
    
    struct ParameterSelectSwitch: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let options: [Option]
        let isEditable: Bool
        let isCollapsable: Bool
        let onChange: Payments.ParameterOnChangeAction
        let process: Payments.ParameterProcessType
        
        init(_ parameter: Parameter, options: [Option], isEditable: Bool = true, isCollapsable: Bool = false, onChange: Payments.ParameterOnChangeAction = .autoContinue, process: Payments.ParameterProcessType = .none) {
            
            self.parameter = parameter
            self.options = options
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.onChange = onChange
            self.process = process
        }
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
            ParameterSelectSwitch(.init(id: parameter.id, value: value), options: options, isEditable: isEditable, isCollapsable: isCollapsable, onChange: onChange, process: process)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterSelectSwitch(parameter, options: options, isEditable: isEditable, isCollapsable: isCollapsable, onChange: onChange, process: process)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
        }
    }
    
    struct ParameterInput: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let validator: Validator
        let isEditable: Bool
        let isCollapsable: Bool
        let process: Payments.ParameterProcessType
        
        init(_ parameter: Parameter, icon: ImageData, title: String, validator: Validator, isEditable: Bool = true, isCollapsable: Bool = false, process: Payments.ParameterProcessType = .none) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.process = process
        }
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
            ParameterInput(.init(id: parameter.id, value: value), icon: icon, title: title, validator: validator,isEditable: isEditable, isCollapsable: isCollapsable, process: process)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, validator: validator, isEditable: isEditable, isCollapsable: isCollapsable, process: process)
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
    
    struct ParameterInfo: PaymentsParameterRepresentable {
        
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
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
            ParameterInfo(.init(id: parameter.id, value: value), icon: icon, title: title, isCollapsable: isCollapsable)
        }
        
        func updated(collapsable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterInfo(parameter, icon: icon, title: title, isCollapsable: collapsable)
        }
    }
    
    struct ParameterName: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        let isEditable: Bool
        let isCollapsable: Bool
        let process: Payments.ParameterProcessType
        
        init(_ parameter: Parameter, title: String, lastName: Name, firstName: Name, middleName: Name, isEditable: Bool = true, isCollapsable: Bool = false, process: Payments.ParameterProcessType = .none) {
            
            self.parameter = parameter
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.isEditable = isEditable
            self.isCollapsable = isCollapsable
            self.process = process
        }
        
        init(id: Parameter.ID, value: String?, title: String, editable: Bool = true, collapsable: Bool = false, process: Payments.ParameterProcessType = .none) {
            
            self.init(.init(id: id, value: value), title: title, lastName: .init(title: "Фамилия", value: name(with: value, index: 0)), firstName: .init(title: "Имя", value: name(with: value, index: 1)), middleName: .init(title: "Отчество", value: name(with: value, index: 2)), isEditable: editable, isCollapsable: collapsable, process: process)
            
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
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
            ParameterName(.init(id: parameter.id, value: value), title: title, lastName: lastName, firstName: firstName, middleName: middleName, isEditable: isEditable, isCollapsable: isCollapsable, process: process)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterName(parameter, title: title, lastName: lastName, firstName: firstName, middleName: middleName, isEditable: isEditable, isCollapsable: isCollapsable, process: process)
        }
        
        struct Name {
            
            let title: String
            let value: String
        }
    }
    
    struct ParameterAmount: PaymentsParameterRepresentable {
        
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
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
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
    
    struct ParameterProduct: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let isEditable: Bool
        let isHidden: Bool
        let onChange: Payments.ParameterOnChangeAction = .updateParameters
        let process: Payments.ParameterProcessType = .initial
        
        init(_ parameter: Parameter, isEditable: Bool, isHidden: Bool) {
            
            self.parameter = parameter
            self.isEditable = isEditable
            self.isHidden = isHidden
        }
        
        init(value: String? = nil, isEditable: Bool = true, isHidden: Bool = true) {
            
            self.init(Parameter(id: Payments.Parameter.Identifier.product.rawValue, value: value), isEditable: isEditable, isHidden: isHidden)
        }
        
        func updated(value: String?) -> PaymentsParameterRepresentable {
            
            ParameterProduct(value: value, isEditable: isEditable, isHidden: isHidden)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterProduct(parameter, isEditable: isEditable, isHidden: isHidden)
        }
        
        func updated(isHidden: Bool) -> PaymentsParameterRepresentable {
            
            ParameterProduct(parameter, isEditable: isEditable, isHidden: isHidden)
        }
    }
    
    struct ParameterFinal: PaymentsParameterRepresentable {
        
        let parameter: Parameter

        internal init() {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.final.rawValue, value: nil)
        }
    }
    
    struct ParameterMock: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let processStep: Int?

        internal init(id: Payments.Parameter.ID = Payments.Parameter.Identifier.mock.rawValue, value: Payments.Parameter.Value = nil, processStep: Int? = nil) {
            
            self.parameter = Parameter(id: id, value: value)
            self.processStep = processStep
        }
    }
}
