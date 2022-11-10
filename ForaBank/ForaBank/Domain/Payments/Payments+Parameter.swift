//
//  Payments+Parameter.swift
//  ForaBank
//
//  Created by Max Gribov on 10.02.2022.
//

import Foundation

//MARK: - Parameter Representable

protocol PaymentsParameterRepresentable {

    var id: Payments.Parameter.ID { get }
    var value: Payments.Parameter.Value { get }
    
    var parameter: Payments.Parameter { get }
    
    /// the paramreter can be edited
    var isEditable: Bool { get }
    
    /// presentation type of the parameter
    var placement: Payments.Parameter.Placement { get }
    
    func updated(value: Payments.Parameter.Value) -> PaymentsParameterRepresentable
}

extension PaymentsParameterRepresentable {

    var id: Payments.Parameter.ID { parameter.id }
    var value: Payments.Parameter.Value { parameter.value }
    
    var isEditable: Bool { false }
    var placement: Payments.Parameter.Placement { .feed }
    
    func updated(value: Payments.Parameter.Value) -> PaymentsParameterRepresentable { self }
}

//MARK: - Parameter Identifier

extension Payments.Parameter {
    
    enum Identifier: String {
        
        case category       = "ru.forabank.sense.category"
        case service        = "ru.forabank.sense.service"
        case `operator`     = "ru.forabank.sense.operator"
        case product        = "ru.forabank.sense.product"
        case amount         = "ru.forabank.sense.amount"
        case code           = "ru.forabank.sense.code"
        case fee            = "ru.forabank.sense.fee"
        case mock           = "ru.forabank.sense.mock"
        
        case sfpPhone       = "RecipientID"
        case sfpBank        = "BankRecipientID"
        case sfpMessage     = "Ustrd"
    }
    
    static let emptyMock = Payments.Parameter(id: Identifier.mock.rawValue, value: nil)
}

//MARK: - Representable Parameters

extension Payments {
    
    struct ParameterSelectService: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let category: Category
        let options: [Option]
        
        init(value: Parameter.Value = nil, category: Category, options: [Option]) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.category.rawValue, value: value)
            self.category = category
            self.options = options
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
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
        
        init(_ parameter: Parameter, title: String, options: [Option], isEditable: Bool = true) {
            
            self.parameter = parameter
            self.title = title
            self.options = options
            self.isEditable = isEditable
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelect(.init(id: parameter.id, value: value), title: title, options: options, isEditable: isEditable)
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
        
        init(_ parameter: Parameter, icon: ImageData, title: String, selectionTitle: String, description: String? = nil, options: [Option], isEditable: Bool = true) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.selectionTitle = selectionTitle
            self.description = description
            self.options = options
            self.isEditable = isEditable
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectSimple(.init(id: parameter.id, value: value), icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, isEditable: isEditable)
        }
    }
    
    struct ParameterSelectSwitch: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let options: [Option]
        let isEditable: Bool
        let placement: Payments.Parameter.Placement
        
        init(_ parameter: Parameter, options: [Option], isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed) {
            
            self.parameter = parameter
            self.options = options
            self.isEditable = isEditable
            self.placement = placement
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectSwitch(.init(id: parameter.id, value: value), options: options, isEditable: isEditable, placement: placement)
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
        let actionButtonType: ActionButtonType?
        let isEditable: Bool
        let placement: Payments.Parameter.Placement
 
        init(_ parameter: Parameter, icon: ImageData, title: String, validator: Validator, isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed, actionButtonType: ActionButtonType? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.actionButtonType = actionButtonType
            self.isEditable = isEditable
            self.placement = placement
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterInput(.init(id: parameter.id, value: value), icon: icon, title: title, validator: validator,isEditable: isEditable, placement: placement, actionButtonType: actionButtonType)
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
        
        enum ActionButtonType {

          case contact
        }
    }
    
    struct ParameterCode: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let timerDelay: TimeInterval
        let errorMessage: String
        let validator: Validator
        let placement: Payments.Parameter.Placement
        
        init(value: Parameter.Value, icon: ImageData, title: String, timerDelay: TimeInterval, errorMessage: String, validator: Validator, placement: Payments.Parameter.Placement = .feed) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.code.rawValue, value: value)
            self.icon = icon
            self.title = title
            self.timerDelay = timerDelay
            self.errorMessage = errorMessage
            self.validator = validator
            self.placement = placement
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterCode(value: value, icon: icon, title: title, timerDelay: timerDelay, errorMessage: errorMessage, validator: validator, placement: placement)
        }
        
        struct Validator: ValidatorProtocol {
            
            let length: Int
            
            func isValid(value: String) -> Bool { value.count == length }
        }
        
        static let regular: ParameterCode = {
            
            let icon = ImageData(named: "ic24MessageSquare") ?? .parameterSample
            
            return ParameterCode(value: nil, icon: icon, title: "Введите код из СМС", timerDelay: 60, errorMessage: "Код введен неправильно", validator: .init(length: 6), placement: .feed)
            
        }()
    }
    
    struct ParameterInfo: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let placement: Payments.Parameter.Placement
        
        init(_ parameter: Parameter, icon: ImageData, title: String, placement: Payments.Parameter.Placement = .feed) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.placement = placement
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterInfo(.init(id: parameter.id, value: value), icon: icon, title: title, placement: placement)
        }
    }
    
    struct ParameterName: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        let isEditable: Bool
        
        init(_ parameter: Parameter, title: String, lastName: Name, firstName: Name, middleName: Name, isEditable: Bool = true) {
            
            self.parameter = parameter
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.isEditable = isEditable
        }
        
        init(id: Parameter.ID, value: String?, title: String, editable: Bool = true) {
            
            self.init(.init(id: id, value: value), title: title, lastName: .init(title: "Фамилия", value: name(with: value, index: 0)), firstName: .init(title: "Имя", value: name(with: value, index: 1)), middleName: .init(title: "Отчество", value: name(with: value, index: 2)), isEditable: editable)
            
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
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterName(.init(id: parameter.id, value: value), title: title, lastName: lastName, firstName: firstName, middleName: middleName, isEditable: isEditable)
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
        let isEditable: Bool
        let placement: Payments.Parameter.Placement = .bottom
        
        var amount: Double {
 
            guard let value = parameter.value, let amount = Double(value) else {
                return 0
            }
            
            return amount
        }

        init(value: Parameter.Value, title: String, currency: Currency, validator: Validator, isEditable: Bool = true) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.amount.rawValue, value: value)
            self.title = title
            self.currency = currency
            self.validator = validator
            self.isEditable = isEditable
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currency: currency, validator: validator, isEditable: isEditable)
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
        var productId: ProductData.ID? {
            
            guard let value = value else {
                return nil
            }
            
            return ProductData.ID(value)
        }
        
        init(value: Parameter.Value, isEditable: Bool) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.product.rawValue, value: value)
            self.isEditable = isEditable
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterProduct(value: value, isEditable: isEditable)
        }
    }
    
    struct ParameterMock: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let placement: Payments.Parameter.Placement

        internal init(id: Payments.Parameter.ID = Payments.Parameter.Identifier.mock.rawValue, value: Payments.Parameter.Value = nil, placement: Payments.Parameter.Placement = .feed) {
            
            self.parameter = Parameter(id: id, value: value)
            self.placement = placement
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterMock(id: parameter.id, value: value)
        }
    }
}
