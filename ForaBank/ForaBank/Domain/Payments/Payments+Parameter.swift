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
    
    /// is paramreter can be edited
    var isEditable: Bool { get }
    
    /// placement of the parameter in the view
    var placement: Payments.Parameter.Placement { get }
    
    /// style of parameter in UI
    var style: Payments.Parameter.Style { get }
    
    /// the group that the parameter belongs to (optional)
    var group: Payments.Parameter.Group? { get }
    
    func updated(value: Payments.Parameter.Value) -> PaymentsParameterRepresentable
}

extension PaymentsParameterRepresentable {

    var id: Payments.Parameter.ID { parameter.id }
    var value: Payments.Parameter.Value { parameter.value }
    
    var isEditable: Bool { false }
    var placement: Payments.Parameter.Placement { .feed }
    var style: Payments.Parameter.Style { .light }
    var group: Payments.Parameter.Group? { nil }
    
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
        case `continue`     = "ru.forabank.sense.continue"
        case mock           = "ru.forabank.sense.mock"
        case subscribe      = "ru.forabank.sense.subscribe"
        case productTemplate = "ru.forabank.sense.productTemplate"
        case productTemplateName = "ru.forabank.sense.productTemplateName"
        
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
        
        case countryPhone                       = "RECP"
        case countryBank                        = "DIRECT_BANKS"
        case countrySelect                      = "trnPickupPoint"
        case countryDropDownList                = "countryDropDownList"
        case countryCurrencyAmount              = "countryCurrencyAmount"
        case countryPayeeAmount                 = "countryPayeeAmount"
        case countryTransferNumber              = "countryTransferNumber"
        case countryPayee                       = "countryPayee"
        case countryDeliveryCurrency            = "CURR"
        case countryDeliveryCurrencyDirect      = "##CURR"
        case countryCheckBox                    = "countryCheckBox"
        case countryOferta                      = "countryOferta"
        case countryCitySearch                  = "search#3#"
        case countryBankSearch                  = "search#5#"
        case countryId                          = "bCountryId"
        case countryCityId                      = "bCityId"
        case trnPickupPointId                   = "trnPickupPointId"
        case countryCurrencyFilter              = "countryCurrencyFilter"
        case countrybSurName                    = "bSurName"
        
        case c2bQrcId                         = "qrcId"
        
        case mobileConnectionPhone = "MobileConnectionPhone"
        case mobileConnectionAmount = "MobileConnectionAmount"
        case mobileConnectionOperatorLogo = "MobileConnectionOperatorLogo"
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
    
    struct ParameterContinue: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        
        init(title: String) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.continue.rawValue, value: nil)
            self.title = title
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
        let icon: ImageData?
        let title: String
        let placeholder: String
        let options: [Option]
        let isEditable: Bool
        let description: String?
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, icon: ImageData? = nil, title: String, placeholder: String, options: [Option], isEditable: Bool = true, description: String? = nil, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.placeholder = placeholder
            self.options = options
            self.isEditable = isEditable
            self.description = description
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelect(.init(id: parameter.id, value: value), icon: icon, title: title, placeholder: placeholder, options: options, isEditable: isEditable, description: description, group: group)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let subname: String?
            let timeWork: String?
            let currency: String?
            let icon: ImageData?
            
            init(id: String, name: String, subname: String? = nil, timeWork: String? = nil, currency: String? = nil, icon: ImageData?) {
                
                self.id = id
                self.name = name
                self.subname = subname
                self.timeWork = timeWork
                self.currency = currency
                self.icon = icon
            }
        }
    }
    
    struct ParameterSelectBank: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let options: [Option]
        let validator: Payments.Validation.RulesSystem
        let limitator: Payments.Limitation?
        let transferType: Payments.Operation.TransferType
        let isEditable: Bool
        let group: Payments.Parameter.Group?

        init(_ parameter: Parameter, icon: ImageData, title: String, options: [Option], validator: Payments.Validation.RulesSystem, limitator: Payments.Limitation?, transferType: Payments.Operation.TransferType, isEditable: Bool = true, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.limitator = limitator
            self.options = options
            self.transferType = transferType
            self.isEditable = isEditable
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectBank(.init(id: parameter.id, value: value), icon: icon, title: title, options: options, validator: validator, limitator: limitator, transferType: transferType, isEditable: isEditable, group: group)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let subtitle: String?
            let icon: ImageData
        }
    }
    
    struct ParameterSelectCountry: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let options: [Option]
        let validator: Payments.Validation.RulesSystem
        let limitator: Payments.Limitation?
        let isEditable: Bool
        let group: Payments.Parameter.Group?

        init(_ parameter: Parameter, icon: ImageData, title: String, options: [Option], validator: Payments.Validation.RulesSystem, limitator: Payments.Limitation?, isEditable: Bool = true, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.validator = validator
            self.limitator = limitator
            self.options = options
            self.isEditable = isEditable
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectCountry(.init(id: parameter.id, value: value), icon: icon, title: title, options: options, validator: validator, limitator: limitator, isEditable: isEditable, group: group)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let subtitle: String?
            let icon: ImageData
        }
    }
    
    //TODO: replace with ParameterSelect
    @available(*, deprecated, message: "Use ParameterSelect instead")
    struct ParameterSelectSimple: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let selectionTitle: String
        let description: String?
        let options: [Option]
        let isEditable: Bool
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, icon: ImageData, title: String, selectionTitle: String, description: String? = nil, options: [Option], isEditable: Bool = true, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.selectionTitle = selectionTitle
            self.description = description
            self.options = options
            self.isEditable = isEditable
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectSimple(.init(id: parameter.id, value: value), icon: icon, title: title, selectionTitle: selectionTitle, description: description, options: options, isEditable: isEditable, group: group)
        }
    }
    
    //TODO: replace with ParameterSelectDropDownList
    @available(*, deprecated, message: "Use ParameterSelectDropDownList instead")
    struct ParameterSelectSwitch: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let options: [Option]
        let isEditable: Bool
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, options: [Option], isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.options = options
            self.isEditable = isEditable
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectSwitch(.init(id: parameter.id, value: value), options: options, isEditable: isEditable, placement: placement, group: group)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
        }
    }
    
    struct ParameterSelectDropDownList: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let options: [Option]
        let isEditable: Bool
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
        let style: Payments.Parameter.Style = .dark
        
        init(_ parameter: Parameter, title: String, options: [Option], isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.title = title
            self.options = options
            self.isEditable = isEditable
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectDropDownList(.init(id: parameter.id, value: value), title: title, options: options, isEditable: isEditable, placement: placement, group: group)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let icon: ImageData?
        }
    }
    
    struct ParameterCheck: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let link: Link?
        let style: Style
        let mode: Mode
        let group: Payments.Parameter.Group?
        var value: Bool {
                        
            return parameter.value == "true" ? true : false
        }
        
        init(_ parameter: Payments.Parameter, title: String, link: Link? = nil, style: Style = .regular, mode: Mode = .normal, group: Payments.Parameter.Group? = nil) {
            self.parameter = parameter
            self.title = title
            self.link = link
            self.style = style
            self.mode = mode
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterCheck(.init(id: parameter.id, value: value), title: title, link: link, style: style, mode: mode, group: group)
        }
        
        struct Link {
            
            let title: String
            let url: URL
        }
        
        enum Style {
            
            case regular
            case c2bSubscribtion
        }
        
        enum Mode {
            
            case normal
            case abroad
        }
    }
    
    struct ParameterInput: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData?
        let title: String
        let hint: Hint?
        let info: String?
        let validator: Payments.Validation.RulesSystem
        let limitator: Payments.Limitation?
        let isEditable: Bool
        let placement: Payments.Parameter.Placement
        let inputType: InputType
        let group: Payments.Parameter.Group?
 
        init(_ parameter: Parameter, icon: ImageData? = nil, title: String, hint: Hint? = nil, info: String? = nil, validator: Payments.Validation.RulesSystem, limitator: Payments.Limitation? = nil, isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed, inputType: InputType = .default, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.hint = hint
            self.info = info
            self.validator = validator
            self.limitator = limitator
            self.isEditable = isEditable
            self.placement = placement
            self.inputType = inputType
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterInput(.init(id: parameter.id, value: value), icon: icon, title: title, hint: hint, info: info, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType, group: group)
        }
        
        func updated(hint: Hint?) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, hint: hint, info: info, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType, group: group)
        }
        
        func updated(icon: ImageData) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, hint: hint, info: info, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType, group: group)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, hint: hint, info: info, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType, group: group)
        }
        
        func updated(validator: Payments.Validation.RulesSystem, inputType: InputType) -> PaymentsParameterRepresentable {
            
            ParameterInput(parameter, icon: icon, title: title, hint: hint, info: info, validator: validator, limitator: limitator, isEditable: isEditable, placement: placement, inputType: inputType, group: group)
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
        let placeholder: String?
        let isEditable: Bool
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
 
        init(_ parameter: Parameter, title: String, placeholder: String? = nil,  isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.title = title
            self.placeholder = placeholder
            self.isEditable = isEditable
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            //FIXME: remove it from here
            let value = value?.replacingOccurrences(of: " ", with: "")
            
            return ParameterInputPhone(.init(id: parameter.id, value: value), title: title, placeholder: placeholder, isEditable: isEditable, placement: placement, group: group)
        }
    }
    
    struct ParameterCode: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let limit: Int?
        let timerDelay: TimeInterval
        let errorMessage: String
        let validator: Validator
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
        
        init(value: Parameter.Value, icon: ImageData, title: String, limit: Int? = nil, timerDelay: TimeInterval, errorMessage: String, validator: Validator, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.code.rawValue, value: value)
            self.icon = icon
            self.title = title
            self.limit = limit
            self.timerDelay = timerDelay
            self.errorMessage = errorMessage
            self.validator = validator
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterCode(value: value, icon: icon, title: title, limit: limit, timerDelay: timerDelay, errorMessage: errorMessage, validator: validator, placement: placement, group: group)
        }
        
        struct Validator: ValidatorProtocol {
            
            let length: Int
            
            func isValid(value: String) -> Bool { value.count == length }
        }
        
        static let regular: ParameterCode = {
            
            let icon = ImageData(named: "ic24SmsCode") ?? .parameterSample
            
            return ParameterCode(value: nil, icon: icon, title: "Введите код из СМС", limit: 6, timerDelay: 60, errorMessage: "Код введен неправильно", validator: .init(length: 6), placement: .feed)
            
        }()
    }
    
    struct ParameterInfo: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, icon: ImageData, title: String, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterInfo(.init(id: parameter.id, value: value), icon: icon, title: title, placement: placement, group: group)
        }
    }
    
    struct ParameterName: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        let isEditable: Bool
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, title: String, lastName: Name, firstName: Name, middleName: Name, isEditable: Bool = true, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.isEditable = isEditable
            self.group = group
        }
        
        init(id: Parameter.ID, value: String?, title: String, editable: Bool = true, group: Payments.Parameter.Group? = nil) {
            
            self.init(.init(id: id, value: value), title: title,
                      lastName: .init(title: "Фамилия", value: Self.name(with: value, index: 0), validator: .baseName, limitator: .init(limit: 158)),
                      firstName: .init(title: "Имя", value: Self.name(with: value, index: 1), validator: .baseName, limitator: .init(limit: 158)),
                      middleName: .init(title: "Отчество (если есть)", value: Self.name(with: value, index: 2), validator: .anyValue, limitator: .init(limit: 158)),
                      isEditable: editable, group: group)
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
        
            ParameterName(.init(id: parameter.id, value: value), title: title,
                          lastName: .init(title: lastName.title, value: Self.name(with: value, index: 0), validator: .baseName, limitator: .init(limit: 158)),
                          firstName: .init(title: firstName.title, value: Self.name(with: value, index: 1), validator: .baseName, limitator: .init(limit: 158)),
                          middleName: .init(title: middleName.title, value: Self.name(with: value, index: 2), validator: .anyValue, limitator: .init(limit: 158)),
                          isEditable: isEditable, group: group)
        }
        
        static func name(with value: String?, index: Int) -> String? {
            
            guard let value = value else {
                return nil
            }
            
            let valueSplitted = value.split(separator: " ")
            switch index {
            case 0:
                guard valueSplitted.count > 0 else {
                    return nil
                }
                return String(valueSplitted[0])
                
            case 1:
                guard valueSplitted.count > 1 else {
                    return nil
                }
                return String(valueSplitted[1])
                
            case 2:
                guard valueSplitted.count > 2 else {
                    return nil
                }
                return String(valueSplitted[2])
                
            default:
                return nil
            }
        }
        
        struct Name {
            
            let title: String
            let value: String?
            let validator: Payments.Validation.RulesSystem
            let limitator: Payments.Limitation
        }
    }
    
    struct ParameterAmount: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let currencySymbol: String
        let deliveryCurrency: DeliveryCurrency?
        let transferButtonTitle: String
        let validator: Validator
        let info: Info?
        let isEditable: Bool
        let placement: Payments.Parameter.Placement = .bottom
        let group: Payments.Parameter.Group?
        
        var amount: Double {
 
            guard let value = parameter.value, let amount = Double(value) else {
                return 0
            }
            
            return amount
        }

        init(value: Parameter.Value, title: String, currencySymbol: String, deliveryCurrency: DeliveryCurrency? = nil, transferButtonTitle: String = "Перевести", validator: Validator, info: Info? = nil, isEditable: Bool = true, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.amount.rawValue, value: value)
            self.title = title
            self.currencySymbol = currencySymbol
            self.deliveryCurrency = deliveryCurrency
            self.transferButtonTitle = transferButtonTitle
            self.validator = validator
            self.info = info
            self.isEditable = isEditable
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: deliveryCurrency, transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable, group: group)
        }
        
        func update(currencySymbol: String, maxAmount: Double?) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: deliveryCurrency, transferButtonTitle: transferButtonTitle, validator: .init(minAmount: 0.01, maxAmount: maxAmount), info: info, isEditable: isEditable, group: group)
        }
        
        func updated(info: Info) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: deliveryCurrency, transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable, group: group)
        }
        
        func updated(selectedCurrency: Currency) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: .init(selectedCurrency: selectedCurrency, currenciesList: deliveryCurrency?.currenciesList), transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable, group: group)
        }
        
        struct DeliveryCurrency {
            
            let selectedCurrency: Currency
            let currenciesList: [Currency]?
        }
        
        //TODO: change to payments validation rule system
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
        let group: Payments.Parameter.Group?
        var productId: ProductData.ID? {
            
            guard let value = value else {
                return nil
            }
            
            return ProductData.ID(value)
        }
        
        init(value: Parameter.Value, title: String = "Счет списания", filter: ProductData.Filter, isEditable: Bool, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.product.rawValue, value: value)
            self.title = title
            self.filter = filter
            self.isEditable = isEditable
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterProduct(value: value, title: title, filter: filter, isEditable: isEditable, group: group)
        }
        
        func updated(filter: ProductData.Filter) -> PaymentsParameterRepresentable {
        
            ParameterProduct(value: value, title: title, filter: filter, isEditable: isEditable, group: group)
        }
    }
    
    struct ParameterProductTemplate: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let placeholder: String
        let validator: Payments.Validation.RulesSystem
        let mask: StringValueMask
        let group: Payments.Parameter.Group?
        let masked: CardMaskData
        let isEditable: Bool
        
        var parameterValue: ParametrValue? {
            
            .init(stringValue: parameter.value)
        }
        
        init(value: ParametrValue?,
             title: String = "Куда",
             placeholder: String = "Номер карты",
             validator: Payments.Validation.RulesSystem,
             mask: StringValueMask = .card,
             group: Payments.Parameter.Group? = nil,
             masked: CardMaskData = .init(),
             isEditable: Bool) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.productTemplate.rawValue, value: value?.stringValue)
            self.placeholder = placeholder
            self.title = title
            self.validator = validator
            self.mask = mask
            self.group = group
            self.masked = masked
            self.isEditable = isEditable
        }
        
        struct CardMaskData {
            let symbol: String = "*"
            let range: [Int] = [5, 6, 7, 8, 10, 11, 12, 13]
        }
        
        enum ParametrValue {
            case cardNumber(String)
            case templateId(String)
            
            var stringValue: String {
                
                switch self {
                case let .cardNumber(cardNumber): return "C:\(cardNumber)"
                case let .templateId(templateId): return "T:\(templateId)"
                }
            }
            
            init?(stringValue: String?) {
               
                guard let stringValue = stringValue,
                      let prefix = stringValue.components(separatedBy: ":").first,
                      let cleanValue = stringValue.components(separatedBy: ":").last
                else { return nil }

                switch prefix {
                case "C": self = .cardNumber(cleanValue)
                case "T": self = .templateId(cleanValue)
            
                default: return nil
                }
            }
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterProductTemplate(value: .init(stringValue: value), title: title, placeholder: placeholder, validator: validator, mask: mask, group: group, isEditable: isEditable)
        }
        
        func updated(isEditable: Bool) -> PaymentsParameterRepresentable {
            
            ParameterProductTemplate(value: .init(stringValue: value), title: title, placeholder: placeholder, validator: validator, mask: mask, group: group, isEditable: isEditable)
        }
        
    }
    
    struct ParameterHeader: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let subtitle: String?
        let style: Style
        let icon: Icon?
        let rightButton: [RightButton]
        //TODO: implement case .header
        let placement: Payments.Parameter.Placement = .top

        init(title: String, subtitle: String? = nil, icon: Icon? = nil, style: Style = .normal, rightButton: [RightButton] = []) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.header.rawValue, value: Payments.Parameter.Identifier.header.rawValue)
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.style = style
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
        
        enum Style {
            
            case normal //24pt
            case large //32pt
        }
        
        func updated(title: String, subtitle: String?, rightButton: [RightButton]) -> PaymentsParameterRepresentable {
            
            ParameterHeader(title: title, subtitle: subtitle, icon: icon, style: style, rightButton: rightButton)
        }
    }
    
    struct ParameterMessage: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let message: String
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
        
        var isViewed: Bool {
            
            guard let value = value else {
                return false
            }
            
            return value == "true" ? true : false
        }
        
        init(_ parameter: Parameter, message: String, placement: Payments.Parameter.Placement = .top, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.message = message
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterMessage(.init(id: parameter.id, value: value), message: message, placement: placement, group: group)
        }
    }
    
    struct ParameterSubscriber: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: String
        let description: String
        
        init(_ parameter: Parameter, icon: String, description: String) {
            
            self.parameter = parameter
            self.icon = icon
            self.description = description
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSubscriber(.init(id: parameter.id, value: value), icon: icon, description: description)
        }
    }
    
    struct ParameterSubscribe: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let buttons: [Button]
        let icon: String
        let placement: Payments.Parameter.Placement = .bottom
        
        init(id: Payments.Parameter.ID = Payments.Parameter.Identifier.subscribe.rawValue, value: Payments.Parameter.Value = nil, buttons: [Button], icon: String) {
            
            self.parameter = .init(id: id, value: value)
            self.buttons = buttons
            self.icon = icon
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSubscribe(id: parameter.id, value: value, buttons: buttons, icon: icon)
        }
        
        struct Button {
            
            let title: String
            let style: Style
            let action: Action
            let precondition: Precondition?

            enum Action: String {
                
                case confirm
                case deny
            }
            
            enum Style {
                
                case primary
                case secondary
            }
            
            struct Precondition {
                
                let parameterId: Payments.Parameter.ID
                let value: Payments.Parameter.Value
            }
        }
    }
    
    struct ParameterDataValue: PaymentsParameterRepresentable {
        
        let parameter: Parameter
    }
    
    struct ParameterHidden: PaymentsParameterRepresentable {
        
        let parameter: Parameter

        internal init(id: Payments.Parameter.ID, value: Payments.Parameter.Value = nil) {
            
            self.parameter = Parameter(id: id, value: value)
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterHidden(id: parameter.id, value: value)
        }
    }
    
    struct ParameterOperatorLogo: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let svgImage: String
        
        init(_ parameter: Parameter, svgImage: String) {
            
            self.parameter = parameter
            self.svgImage = svgImage
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterOperatorLogo(
                .init(id: parameter.id, value: value),
                svgImage: svgImage
            )
        }
    }
    
    struct ParameterMock: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?

        internal init(id: Payments.Parameter.ID = Payments.Parameter.Identifier.mock.rawValue, value: Payments.Parameter.Value = nil, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = Parameter(id: id, value: value)
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterMock(id: parameter.id, value: value, group: group)
        }
    }
}

extension Payments.Validation.RulesSystem {
    
    static let baseName: Payments.Validation.RulesSystem = {
        
        let minRule = Payments.Validation.MinLengthRule(minLenght: 1, actions: [.post: .warning("Поле обязательно для заполнения")])
        let maxRule = Payments.Validation.MaxLengthRule(maxLenght: 158, actions: [.post: .warning("Количество символов не должно превышать 158")])
        let regExp = Payments.Validation.RegExpRule(regExp:"^[\\s\\-_\\.a-zA-ZА-Яа-яЁё]+$", actions: [.post: .warning("Введены недопустимые символы")])
        
        return Payments.Validation.RulesSystem(rules: [minRule, maxRule, regExp])
    }()
}
