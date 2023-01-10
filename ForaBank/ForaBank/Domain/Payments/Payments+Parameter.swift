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
        case header         = "ru.forabank.sense.header"
        case product        = "ru.forabank.sense.product"
        case amount         = "ru.forabank.sense.amount"
        case code           = "ru.forabank.sense.code"
        case fee            = "ru.forabank.sense.fee"
        case mock           = "ru.forabank.sense.mock"
        
        case sfpPhone       = "RecipientID"
        case sfpBank        = "BankRecipientID"
        case sftRecipient   = "RecipientNm"
        case sfpAmount      = "SumSTrs"
        case sfpMessage     = "Ustrd"
        case sfpAntifraud   = "AFResponse"
        
        case requisitsBankBic                 = "requisitsBankBic"
        case requisitsAccountNumber           = "requisitsAccountNumber"
        case requisitsName                    = "requisitsName"
        case requisitsMessage                 = "requisitsMessage"
        case requisitsAmount                  = "requisitsAmount"
        case requisitsInn                     = "requisitsInn"
        case requisitsKpp                     = "requisitsKpp"
        case requisitsCompanyName             = "requisitsCompanyName"
        case requisitsCheckBox                = "requisitsCheckBox"
        case requisitsType                    = "requisitsType"
        case requisitsPopUpSelector           = "requisitsPopUpSelector"

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
    
    struct ParameterRequisitesType: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        var type: BicAccountCheck.CheckResult? {
            
            guard let value = parameter.value else {
                return nil
            }
            
            return BicAccountCheck.CheckResult(rawValue: value)
        }
        
        init(type: BicAccountCheck.CheckResult) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.requisitsType.rawValue, value: type.rawValue)
        }
    }
    
    struct ParameterSelect: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let options: [Option]
        let isEditable: Bool
        let type: Kind
        
        init(_ parameter: Parameter, title: String, options: [Option], isEditable: Bool = true, type: Kind = .general) {
            
            self.parameter = parameter
            self.title = title
            self.options = options
            self.isEditable = isEditable
            self.type = type
        }
        
        enum Kind {
            
            case general
            case banks
            case countries
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelect(.init(id: parameter.id, value: value), title: title, options: options, isEditable: isEditable, type: type)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let icon: ImageData
        }
    }
    
    struct ParameterSelectBank: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let options: [Option]
        let isEditable: Bool
        let validator: Payments.Validation.RulesSystem
        let limitator: Payments.Limitation?

        init(_ parameter: Parameter, icon: ImageData, title: String, options: [Option], validator: Payments.Validation.RulesSystem, limitator: Payments.Limitation?, isEditable: Bool = true) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.limitator = limitator
            self.options = options
            self.isEditable = isEditable
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectBank(.init(id: parameter.id, value: value), icon: icon, title: title, options: options, validator: validator, limitator: limitator, isEditable: isEditable)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let subtitle: String?
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
    
    struct ParameterCheckBox: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        var value: Bool {
                        
            guard parameter.value == "true" else {
                return true
            }
            
            return false
        }
        
        internal init(_ parameter: Payments.Parameter, title: String) {
            self.parameter = parameter
            self.title = title
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterCheckBox(.init(id: parameter.id, value: value), title: title)
        }
    }
    
    struct ParameterInput: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData?
        let title: String
        let hint: Hint?
        let validator: Payments.Validation.RulesSystem
        let limitator: Payments.Limitation?
        let isEditable: Bool
        let inputType: InputType
        let placement: Payments.Parameter.Placement
 
        init(_ parameter: Parameter, icon: ImageData? = nil, title: String, hint: Hint? = nil, validator: Payments.Validation.RulesSystem, limitator: Payments.Limitation? = nil, isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed, inputType: InputType = .default) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.hint = hint
            self.validator = validator
            self.limitator = limitator
            self.isEditable = isEditable
            self.placement = placement
            self.inputType = inputType
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterInput(.init(id: parameter.id, value: value), icon: icon, title: title, hint: hint, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType)
        }
        
        func updated(hint: Hint?) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, hint: hint, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType)
        }
        
        func updated(icon: ImageData) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, hint: hint, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, hint: hint, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement)
        }
        
        enum InputType {
            case `default`
            case number
        }
        
        struct Hint {
            
            let title: String
            let subtitle: String
            let icon: Data
            let hints: [Content]
            
            struct Content {
                
                let title: String
                let description: String
            } 
        }
    }
    
    struct ParameterInputPhone: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let isEditable: Bool
        let placement: Payments.Parameter.Placement
 
        init(_ parameter: Parameter, title: String, isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed) {
            
            self.parameter = parameter
            self.title = title
            self.isEditable = isEditable
            self.placement = placement
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterInputPhone(.init(id: parameter.id, value: value), title: title, isEditable: isEditable, placement: placement)
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
            
            self.init(.init(id: id, value: value), title: title, lastName: .init(title: "Фамилия", value: Self.name(with: value, index: 0)), firstName: .init(title: "Имя", value: Self.name(with: value, index: 1)), middleName: .init(title: "Отчество", value: Self.name(with: value, index: 2)), isEditable: editable)
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
        
            ParameterName(.init(id: parameter.id, value: value), title: title, lastName: .init(title: lastName.title, value: Self.name(with: value, index: 0)), firstName: .init(title: firstName.title, value: Self.name(with: value, index: 1)), middleName: .init(title: middleName.title, value: Self.name(with: value, index: 2)), isEditable: isEditable)
        }
        
        static func name(with value: String?, index: Int) -> String {
            
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
        
        struct Name {
            
            let title: String
            let value: String
        }
    }
    
    struct ParameterAmount: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let currencySymbol: String
        let transferButtonTitle: String
        let validator: Validator
        let info: Info?
        let isEditable: Bool
        let placement: Payments.Parameter.Placement = .bottom
        
        var amount: Double {
 
            guard let value = parameter.value, let amount = Double(value) else {
                return 0
            }
            
            return amount
        }

        init(value: Parameter.Value, title: String, currencySymbol: String, transferButtonTitle: String = "Перевести", validator: Validator, info: Info? = nil, isEditable: Bool = true) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.amount.rawValue, value: value)
            self.title = title
            self.currencySymbol = currencySymbol
            self.transferButtonTitle = transferButtonTitle
            self.validator = validator
            self.info = info
            self.isEditable = isEditable
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable)
        }
        
        func updated(info: Info) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable)
        }
        
        struct Validator: ValidatorProtocol, Equatable {
            
            let minAmount: Double
            let maxAmount: Double?
            
            func isValid(value: Double) -> Bool {
                
                guard value >= minAmount else {
                    return false
                }
                
                if let maxAmount = maxAmount {
                    
                    return value <= maxAmount
                    
                } else {
                    
                    return true
                }
            }
        }
        
        enum Info: Equatable {
            
            case action(title: String, Icon, Action)
            
            enum Icon: Equatable {
                
                case image(ImageData)
                case name(String)
            }
            
            enum Action {
                
                case feeInfo
            }
        }
    }
    
    struct ParameterProduct: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let filter: ProductData.Filter
        let isEditable: Bool
        var productId: ProductData.ID? {
            
            guard let value = value else {
                return nil
            }
            
            return ProductData.ID(value)
        }
        
        init(value: Parameter.Value, title: String = "Счет списания", filter: ProductData.Filter, isEditable: Bool) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.product.rawValue, value: value)
            self.title = title
            self.filter = filter
            self.isEditable = isEditable
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterProduct(value: value, title: title, filter: filter, isEditable: isEditable)
        }
    }
    
    struct ParameterHeader: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let subtitle: String?
        let icon: Icon?
        let rightButton: [RightButton]
        //TODO: implement case .header
        let placement: Payments.Parameter.Placement = .top

        init(title: String, subtitle: String? = nil, icon: Icon? = nil, rightButton: [RightButton] = []) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.header.rawValue, value: Payments.Parameter.Identifier.header.rawValue)
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.rightButton = rightButton
        }
        
        struct RightButton {
               
          let icon: ImageData
          let action: ActionType
         
          enum ActionType {

            case scanQrCode
          }
       }
        
        enum Icon {
            
            case image(ImageData)
            case name(String)
        }
        
        func updated(title: String, subtitle: String?, rightButton: [RightButton]) -> PaymentsParameterRepresentable {
            
            ParameterHeader(title: title, subtitle: subtitle, icon: icon, rightButton: rightButton)
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
