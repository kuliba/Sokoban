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
        
        case category                        = "ru.forabank.sense.category"
        case service                         = "ru.forabank.sense.service"
        case `operator`                      = "ru.forabank.sense.operator"
        case header                          = "ru.forabank.sense.header"
        case product                         = "ru.forabank.sense.product"
        case amount                          = "ru.forabank.sense.amount"
        case code                            = "ru.forabank.sense.code"
        case fee                             = "ru.forabank.sense.fee"
        case `continue`                      = "ru.forabank.sense.continue"
        case mock                            = "ru.forabank.sense.mock"
        case subscribe                       = "ru.forabank.sense.subscribe"
        case productTemplate                 = "ru.forabank.sense.productTemplate"
        case productTemplateName             = "ru.forabank.sense.productTemplateName"
        
        case successStatus = "ru.forabank.sense.success.status"
        case successOptionButtons = "ru.forabank.sense.success.optionButtons"
        case successMode = "ru.forabank.sense.success.mode"
        case successOperationDetailID = "ru.forabank.sense.success.operationDetailID"
        case successTitle = "ru.forabank.sense.success.title"
        case successAmount = "ru.forabank.sense.success.amount"
        case successActionButton = "ru.forabank.sense.success.actionButton"
        case successCloseButton = "ru.forabank.sense.success.closeButton"
        case successRepeatButton = "ru.forabank.sense.success.repeatButton"
        case successLogo = "ru.forabank.sense.success.successLogo"
        case successAdditionalButtons = "ru.forabank.sense.success.successAdditionalButtons"
        case successTransferNumber = "ru.forabank.sense.success.successTransferNumber"
        case successOptions = "ru.forabank.sense.success.successOptions"
        case successService = "ru.forabank.sense.success.successService"
        case successSubscriptionToken = "ru.forabank.sense.success.successSubscriptionToken"

        case sfpPhone       = "RecipientID"
        case sfpBank        = "BankRecipientID"
        case sftRecipient   = "RecipientNm"
        case sfpAmount      = "SumSTrs"
        case sfpMessage     = "Ustrd"
        case sfpAntifraud   = "AFResponse"
        
        case requisitsBankBic                = "requisitsBankBic"
        case requisitsAccountNumber          = "requisitsAccountNumber"
        case requisitsName                   = "requisitsName"
        case requisitsMessage                = "requisitsMessage"
        case requisitsAmount                 = "requisitsAmount"
        case requisitsInn                    = "requisitsInn"
        case requisitsKpp                    = "requisitsKpp"
        case requisitsCompanyName            = "requisitsCompanyName"
        case requisitsCompanyNameHelper      = "requisitsCompanyName_Helper"
        case requisitsCheckBox               = "requisitsCheckBox"
        case requisitsType                   = "requisitsType"
        
        case countryPhone                    = "RECP"
        case countrybPhone                   = "bPhone"
        case countryBank                     = "DIRECT_BANKS"
        case countrySelect                   = "trnPickupPoint"
        case countryDropDownList             = "countryDropDownList"
        case countryCurrencyAmount           = "countryCurrencyAmount"
        case countryPayeeAmount              = "countryPayeeAmount"
        case countryTransferNumber           = "countryTransferNumber"
        case countryPayee                    = "countryPayee"
        case countryDeliveryCurrency         = "CURR"
        case countryDeliveryCurrencyDirect   = "##CURR"
        case countryOffer                    = "countryOferta"
        case countryDividend                 = "countryDividend"
        case countryCitySearch               = "search#3#"
        case countryBankSearch               = "search#5#"
        case countryId                       = "bCountryId"
        case countryCity                     = "bCityId"
        case trnPickupPoint                  = "trnPickupPointId"
        case countryCurrencyFilter           = "countryCurrencyFilter"
        case countryFamilyName               = "bSurName"
        case countryGivenName                = "bName"
        case countryMiddleName               = "bLastName"
        case paymentSystem                   = "paymentSystem"
        
        case countryReturnNumber             = "countryReturnNumber"
        case countryReturnAmount             = "countryReturnAmount"
        case countryReturnName               = "countryReturnName"
        case countryOperationId              = "countryOperationId"
        
        case c2bQrcId                        = "qrcId"
        case c2bIsAmountComplete             = "c2bIsAmountComplete"
        
        case mobileConnectionPhone           = "MobileConnectionPhone"
        case mobileConnectionAmount          = "MobileConnectionAmount"
        case mobileConnectionOperatorLogo    = "MobileConnectionOperatorLogo"
        
        case paymentsServiceOperatorLogo     = "paymentsServiceOperatorLogo"
        case paymentsServiceAmount           = "paymentsServiceAmount"

        case p1                              = "P1"
        case mosParking                      = "MosParking"
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
        
        init(operatorType: String) {
            
            self.parameter = Parameter(id: Payments.Parameter.Identifier.operator.rawValue, value: operatorType)
        }

    }
    
    struct ParameterButton: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let style: Style
        let action: Action
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
        
        init(parameterId: Parameter.ID = UUID().uuidString, title: String, style: Style, acton: Action, placement: Payments.Parameter.Placement = .bottom, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = Parameter(id: parameterId, value: nil)
            self.title = title
            self.style = style
            self.action = acton
            self.placement = placement
            self.group = group
        }
        
        init(with parameter: PaymentParameterButton) {
            
            self.init(parameterId: parameter.id, title: parameter.value, style: parameter.color, acton: parameter.action, placement: parameter.placement)
        }
        
        enum Style: String {
            
            case primary = "red"
            case secondary = "white"
        }
        
        enum Action: String, Decodable {
            
            case `continue` = "PAY"
            case save = "SAVE"
            case cancel = "CANCEL"
            case update = "UPDATE"
            case cancelSubscribe = "CANCEL_SUB"
            case main = "MAIN"
            case `repeat`
            case additionalChange
            case additionalReturn
            case close
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
        let icon: Icon?
        let title: String
        let placeholder: String
        let options: [Option]
        let isEditable: Bool
        let description: String?
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, icon: Icon? = nil, title: String, placeholder: String, options: [Option], isEditable: Bool = true, description: String? = nil, group: Payments.Parameter.Group? = nil) {
            
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
        
        enum Icon {
            
            case image(ImageData)
            case name(String)
        }
        
        struct Option: Identifiable {
            
            let id: String
            let name: String
            let subname: String?
            let timeWork: String?
            let currencies: [String]?
            let icon: Icon
            
            init(id: String, name: String, subname: String? = nil, timeWork: String? = nil, currencies: [String]? = nil, icon: Icon = .circle) {
                
                self.id = id
                self.name = name
                self.subname = subname
                self.timeWork = timeWork
                self.currencies = currencies
                self.icon = icon
            }
            
            init(id: String, name: String, subname: String? = nil, timeWork: String? = nil, currenciesData: String?, icon: Icon = .circle) {
                
                let currencies = currenciesData?.components(separatedBy: ";").dropLast().map { $0 }
                self.init(id: id, name: name, subname: subname, timeWork: timeWork, currencies: currencies, icon: icon)
            }
            
            enum Icon {
                
                case image(ImageData)
                case circle
            }
        }
    }
    
    struct ParameterSelectBank: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let options: [Option]
        let placeholder: String
        let selectAll: SelectAllOption?
        let keyboardType: KeyboardType
        let isEditable: Bool
        let group: Payments.Parameter.Group?

        init(_ parameter: Parameter, icon: ImageData, title: String, options: [Option], placeholder: String, selectAll: SelectAllOption? = nil, keyboardType: KeyboardType, isEditable: Bool = true, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.options = options
            self.placeholder = placeholder
            self.selectAll = selectAll
            self.keyboardType = keyboardType
            self.isEditable = isEditable
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSelectBank(.init(id: parameter.id, value: value), icon: icon, title: title, options: options, placeholder: placeholder, selectAll: selectAll, keyboardType: keyboardType, isEditable: isEditable, group: group)
        }
        
        func updated(options: [ParameterSelectBank.Option]) -> PaymentsParameterRepresentable {
            
            ParameterSelectBank(.init(id: parameter.id, value: parameter.value), icon: icon, title: title, options: options, placeholder: placeholder, selectAll: selectAll, keyboardType: keyboardType, isEditable: isEditable, group: group)
        }
        
        struct Option: Identifiable, Equatable {
    
            let id: String
            let name: String
            let subtitle: String?
            let icon: ImageData?
            let isFavorite: Bool
            let searchValue: String
        }
        
        enum KeyboardType {
            
            case normal
            case number
        }
        
        struct SelectAllOption {
            
            var iconName: String = "ic24MoreHorizontal"
            var title: String = "Cмотреть все"
            let type: Kind
            
            enum Kind {
                
                case banks
                case banksFullInfo
            }
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
        
        struct Option: Identifiable, Equatable {
            
            let id: String
            let name: String
            let icon: Icon?
            
            enum Icon: Equatable {
                
                case image(ImageData)
                case name(String)
            }
        }
    }
    
    struct ParameterCheck: PaymentsParameterRepresentable, Equatable {
        
        let parameter: Parameter
        let title: String
        let urlString: String?
        let style: Style
        let mode: Mode
        let group: Payments.Parameter.Group?
        var value: Bool {
                        
            return parameter.value == "true" ? true : false
        }
        
        init(
            _ parameter: Payments.Parameter,
            title: String,
            urlString: String?,
            style: Style = .regular,
            mode: Mode = .normal,
            group: Payments.Parameter.Group? = nil
        ) {
            self.parameter = parameter
            self.title = title
            self.urlString = urlString
            self.style = style
            self.mode = mode
            self.group = group
        }
        
        func updated(
            value: Parameter.Value
        ) -> PaymentsParameterRepresentable {
            
            ParameterCheck(
                .init(id: parameter.id, value: value),
                title: title,
                urlString: urlString,
                style: style,
                mode: mode,
                group: group
            )
        }
                
        enum Style: Equatable {
            
            case regular
            case c2bSubscription
        }
        
        enum Mode: Equatable {
            
            case normal
            case requisites
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
            let icon: ImageData
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
        let countryCode: [CountryCodeReplace]?
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
 
        init(_ parameter: Parameter, title: String, placeholder: String? = nil, countryCode: [CountryCodeReplace]? = nil, isEditable: Bool = true, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.title = title
            self.placeholder = placeholder
            self.countryCode = countryCode
            self.isEditable = isEditable
            self.placement = placement
            self.group = group
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            //FIXME: remove it from here
            let value = value?.replacingOccurrences(of: " ", with: "")
            
            return ParameterInputPhone(.init(id: parameter.id, value: value), title: title, placeholder: placeholder, countryCode: countryCode, isEditable: isEditable, placement: placement, group: group)
        }
    }
    
    struct ParameterCode: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let icon: ImageData
        let title: String
        let limit: Int?
        let timerDelay: TimeInterval
        let errorMessage: String
        //TODO: refactor to Payments.Validation.RulesSystem
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
    
    struct ParameterInfo: PaymentsParameterRepresentable, Equatable {
        
        let parameter: Parameter
        let icon: Payments.Parameter.Icon
        let title: String
        let lineLimit: Int?
        let placement: Payments.Parameter.Placement
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, icon: Payments.Parameter.Icon, title: String, lineLimit: Int? = nil, placement: Payments.Parameter.Placement = .feed, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.icon = icon
            self.title = title
            self.lineLimit = lineLimit
            self.placement = placement
            self.group = group
        }
        
        init(with qrParameter: PaymentParameterInfo) {
            
            self.init(.init(id: qrParameter.id, value: qrParameter.value), icon: qrParameter.icon.parameterIcon, title: qrParameter.title)
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterInfo(.init(id: parameter.id, value: value), icon: icon, title: title, lineLimit: lineLimit, placement: placement, group: group)
        }
    }
    
    struct ParameterName: PaymentsParameterRepresentable {
        
        let parameter: Parameter
        let title: String
        let lastName: Name
        let firstName: Name
        let middleName: Name
        let isEditable: Bool
        let mode: Mode
        let group: Payments.Parameter.Group?
        
        init(_ parameter: Parameter, title: String, lastName: Name, firstName: Name, middleName: Name, isEditable: Bool = true, mode: Mode = .regular, group: Payments.Parameter.Group? = nil) {
            
            self.parameter = parameter
            self.title = title
            self.lastName = lastName
            self.firstName = firstName
            self.middleName = middleName
            self.isEditable = isEditable
            self.mode = mode
            self.group = group
        }
        
        init(id: Parameter.ID, value: String?, title: String, editable: Bool = true, mode: Mode = .regular, group: Payments.Parameter.Group? = nil) {
            
            self.init(.init(id: id, value: value), title: title,
                      lastName: .init(title: "Фамилия", value: Self.name(with: value, index: 0), validator: .baseName, limitator: .init(limit: 158)),
                      firstName: .init(title: "Имя", value: Self.name(with: value, index: 1), validator: .baseName, limitator: .init(limit: 158)),
                      middleName: .init(title: "Отчество (если есть)", value: Self.name(with: value, index: 2), validator: .anyValue, limitator: .init(limit: 158)),
                      isEditable: editable, mode: mode, group: group)
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
        
            ParameterName(.init(id: parameter.id, value: value), title: title,
                          lastName: .init(title: lastName.title, value: Self.name(with: value, index: 0), validator: .baseName, limitator: .init(limit: 158)),
                          firstName: .init(title: firstName.title, value: Self.name(with: value, index: 1), validator: .baseName, limitator: .init(limit: 158)),
                          middleName: .init(title: middleName.title, value: Self.name(with: value, index: 2), validator: .anyValue, limitator: .init(limit: 158)),
                          isEditable: isEditable, mode: mode, group: group)
        }
        
        enum Mode {
            
            case regular
            case abroad
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
        
        func updated(currencySymbol: String) -> Payments.ParameterAmount {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: deliveryCurrency, transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable, group: group)
        }
        
        func updated(info: Info) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: deliveryCurrency, transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable, group: group)
        }
        
        func updated(value: Parameter.Value, selectedCurrency: Currency) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: .init(selectedCurrency: selectedCurrency, currenciesList: deliveryCurrency?.currenciesList), transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable, group: group)
        }
        
        func updated(value: Parameter.Value, deliveryCurrency: DeliveryCurrency) -> PaymentsParameterRepresentable {
            
            ParameterAmount(value: value, title: title, currencySymbol: currencySymbol, deliveryCurrency: deliveryCurrency, transferButtonTitle: transferButtonTitle, validator: validator, info: info, isEditable: isEditable, group: group)
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
        let isAutoContinue: Bool = true
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
            case editName(TemplatesListViewModel.RenameTemplateItemViewModel)
          }
       }
        
        enum Icon {
            
            case image(ImageData)
            case name(String)
            
            init?(source: Payments.Operation.Source?) {
                
                switch source {
                case .sfp(_, let bankId):
                    if bankId != BankID.foraBankID.rawValue {
                        self = .name("ic24Sbp")
                    } else {
                        return nil
                    }
                default:
                    self = .name("ic24Sbp")
                }
            }
            
            init?(parameters: [PaymentsParameterRepresentable]) {
                
                guard let bankParameterValue = try? parameters.value(forId: Payments.Parameter.Identifier.sfpBank.rawValue),
                      bankParameterValue != BankID.foraBankID.rawValue
                else { return nil }
                self = .name("ic24Sbp")
            }
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
        let description: String?
        let style: Style
        
        init(_ parameter: Parameter, icon: String, description: String?, style: Style = .regular) {
            
            self.parameter = parameter
            self.icon = icon
            self.description = description
            self.style = style
        }
        
        init(with subscriptionData: C2BSubscriptionData) {
            
            self.init(
                .init(id: UUID().uuidString, value: subscriptionData.brandName),
                icon: subscriptionData.brandIcon,
                description: subscriptionData.legalName,
                style: .small
            )
        }
        
        init(with parameter: PaymentParameterSubscriber) {
            
            self.init(
                .init(id: parameter.id, value: parameter.value),
                icon: parameter.icon,
                description: parameter.description,
                style: parameter.style
            )
        }
        
        func updated(value: Parameter.Value) -> PaymentsParameterRepresentable {
            
            ParameterSubscriber(.init(id: parameter.id, value: value), icon: icon, description: description, style: style)
        }
        
        enum Style: String, Decodable {
            
            case regular = "REGULAR"
            case small = "SMALL"
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
            
            ParameterMock(id: parameter.id, value: value, placement: placement, group: group)
        }
    }
}

extension Payments.ParameterSelect.Option {

  init(with option: Option) {
    
    self.init(id: option.id, name: option.name, subname: option.subtitle)
  }
}

//MARK: - Success Parameters

extension Payments {
    
    struct ParameterSuccessStatus: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        var status: Status {
            
            guard let value = parameter.value,
                    let status = Status(rawValue: value) else {
                
                return .error
            }
            
            return status
        }
        
        init(status: Status) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successStatus.rawValue, value: status.rawValue)
        }
        
        init(with documentStatus: TransferResponseBaseData.DocumentStatus) {
            
            switch documentStatus {
            case .complete:
                self.init(status: .success)

            case .inProgress:
                self.init(status: .accepted)
            
            case .suspended:
                self.init(status: .suspended)

            case .rejected, .unknown:
                self.init(status: .error)
            }
        }
        
        init(with status: C2BSubscriptionData.Status) {
            
            switch status {
            case .complete:
                self.init(status: .success)
                
            case .rejected:
                self.init(status: .error)
                
            default:
                self.init(status: .accepted)
            }
        }
        
        init(with parameter: PaymentParameterStatus) {
            
            switch parameter.value {
            case .complete:
                self.init(status: .success)
                
            case .rejected:
                self.init(status: .error)
            
            case .suspended:
                self.init(status: .suspended)
                
            default:
                self.init(status: .accepted)
            }
        }
        
        enum Status: String {
            
            case success
            case accepted
            case transfer
            case suspended
            case error
        }
    }
    
    struct ParameterSuccessText: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let style: Style
        let placement: Payments.Parameter.Placement
        
        init(id: Parameter.ID = UUID().uuidString, value: String, style: Style, placement: Payments.Parameter.Placement = .feed) {
            
            self.parameter = .init(id: id, value: value)
            self.style = style
            self.placement = placement
        }
        
        init(with parameter: PaymentParameterText) {
            
            self.init(id: parameter.id, value: parameter.value, style: parameter.style)
        }
        
        enum Style: String, Decodable {
            
            case title = "TITLE"
            case subtitle = "SUBTITLE"
            case amount = "AMOUNT"
            case warning = "WARNING"
            case message = "MESSAGE"
        }
    }
    
    struct ParameterSuccessIcon: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let icon: Icon
        let size: Size
        let placement: Payments.Parameter.Placement
        
        init(id: Parameter.ID = UUID().uuidString, icon: Icon, size: Size, placement: Payments.Parameter.Placement = .feed) {
            
            self.parameter = .init(id: id, value: nil)
            self.icon = icon
            self.size = size
            self.placement = placement
        }
        
        init(with parameter: PaymentParameterIcon) {
            
            //TODO: implement icon remote
            switch parameter.iconType {
            case .local:
                self.init(id: parameter.id, icon: .name(parameter.value), size: .normal, placement: parameter.placement)
                
            case .remote:
                self.init(id: parameter.id, icon: .image(.iconPlaceholder), size: .normal, placement: parameter.placement)
                
            }
        }
        
        enum Icon {
            
            case image(ImageData)
            case name(String)
        }
        
        enum Size {
            
            case normal
            case small
        }
    }
    
    struct ParameterSuccessOptionButtons: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let options: [Option]
        let operationDetail: OperationDetailData?
        let placement: Payments.Parameter.Placement
        let templateID: PaymentTemplateData.ID?
        let meToMePayment: MeToMePayment?
        let operation: Payments.Operation?
        
        init(
            options: [Option],
            operationDetail: OperationDetailData? = nil,
            placement: Payments.Parameter.Placement = .feed,
            templateID: PaymentTemplateData.ID?,
            meToMePayment: MeToMePayment?,
            operation: Payments.Operation?
        ) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successOptionButtons.rawValue, value: nil)
            self.options = options
            self.operationDetail = operationDetail
            self.placement = placement
            self.templateID = templateID
            self.meToMePayment = meToMePayment
            self.operation = operation
        }
        
        init(
            with parameter: PaymentParameterOptionButtons,
            templateID: PaymentTemplateData.ID?,
            operation: Payments.Operation?,
            meToMePayment: MeToMePayment?
        ) {
            
            self.init(
                options: parameter.value,
                placement: .feed,
                templateID: templateID,
                meToMePayment: meToMePayment,
                operation: operation
            )
        }

        enum Option: String, Decodable, CaseIterable {
            
            case details = "DETAILS"
            case document = "DOCUMENT"
            case template = "TEMPLATE"
        }
    }
    
    struct ParameterSuccessLink: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let title: String
        let url: URL
        
        init(parameterId: Payments.Parameter.ID, title: String, url: URL) {
            
            self.parameter = .init(id: parameterId, value: nil)
            self.title = title
            self.url = url
        }
        
        init?(with subscriptionData: C2BSubscriptionData) {
            
            guard let url = subscriptionData.redirectUrl else {
                return nil
            }
            
            self.init(parameterId: UUID().uuidString, title: "Вернуться в магазин", url: url)
        }
        
        init(with parameter: PaymentParameterLink) {
            
            self.init(parameterId: parameter.id, title: parameter.title, url: parameter.value)
        }
    }
    
    struct ParameterSuccessMode: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        //TODO: extract mode type from ViewModel
        let mode: PaymentsSuccessViewModel.Mode
        
        init(mode: PaymentsSuccessViewModel.Mode) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successMode.rawValue, value: nil)
            self.mode = mode
        }
    }
    
    struct ParameterSuccessAdditionalButtons: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let options: [Option]
        let placement: Payments.Parameter.Placement
        
        init(options: [Option], placement: Payments.Parameter.Placement = .bottom) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successAdditionalButtons.rawValue, value: nil)
            self.options = options
            self.placement = placement
        }
        
        enum Option: CaseIterable {
            
            case change
            case `return`
            
            var title: String {
                
                switch self {
                case .change: return "Изменить"
                case .return: return "Вернуть"
                }
            }
        }
    }
    
    struct ParameterSuccessTransferNumber: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        
        init(number: String) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successTransferNumber.rawValue, value: number)
        }
    }
    
    struct ParameterSuccessLogo: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let icon: Icon
        
        init(icon: Icon, title: String? = nil) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successLogo.rawValue, value: title)
            self.icon = icon
        }
        
        enum Icon {
            
            case image(ImageData)
            case name(String)
            case sfp
        }
    }
    
    struct ParameterSuccessOptions: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let options: [Option]
        
        init(options: [Option]) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successOptions.rawValue, value: nil)
            self.options = options
        }
        
        struct Option {
            
            let icon: Icon
            let title: String
            let subTitle: String?
            let description: String
        }
        
        enum Icon {
            
            case image(ImageData)
            case name(String)
        }
    }
    
    struct ParameterSuccessService: PaymentsParameterRepresentable {
        
        let parameter: Payments.Parameter
        let description: String
        
        init(title: String, description: String) {
            
            self.parameter = .init(id: Payments.Parameter.Identifier.successService.rawValue, value: title)
            self.description = description
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


extension Array where Element == PaymentsParameterRepresentable {

    var parameterAmount: Payments.ParameterAmount? {
        compactMap {
            $0 as? Payments.ParameterAmount
        }.first
    }
    
    var parameterProduct: Payments.ParameterProduct? {
        compactMap {
            $0 as? Payments.ParameterProduct
        }.first
    }
    
    var phoneParameterValue: String {
        get throws {
            try value(forIdentifier: .mobileConnectionPhone)
        }
    }
    
    func parameter(
        forIdentifier identifier: Payments.Parameter.Identifier
    ) throws -> Element {
        
        try parameter(forId: identifier.rawValue)
    }
    
    func parameter(
        forId parameterId: Payments.Parameter.ID
    ) throws -> Element {
        
        guard let parameter = first(where: { $0.id == parameterId })
        else {
            throw Payments.Error.missingParameter(parameterId)
        }
        
        return parameter
    }
    
    func parameter<T: PaymentsParameterRepresentable>(
        forIdentifier identifier: Payments.Parameter.Identifier,
        as type: T.Type
    ) throws -> T {
        
        try parameter(forId: identifier.rawValue, as: type)
    }
    
    func parameter<T: PaymentsParameterRepresentable>(
        forId parameterId: Payments.Parameter.ID,
        as type: T.Type
    ) throws -> T {
        
        guard let parameter = first(where: { $0.id == parameterId })
        else {
            throw Payments.Error.missingParameter(parameterId)
        }
        
        guard let result = parameter as? T
        else {
            throw Payments.Error.unableCreateRepresentable(parameterId)
        }
        
        return result
    }
    
    func value(
        forIdentifier identifier: Payments.Parameter.Identifier
    ) throws -> String {
        
        try value(forId: identifier.rawValue)
    }
    
    func value(
        forId parameterId: Payments.Parameter.ID
    ) throws -> String {
        
        guard let value = try parameter(forId: parameterId).value
        else {
            throw Payments.Error.missingValueForParameter(parameterId)
        }
        
        return value
    }
    
    func hasValue(
        forIdentifier identifier: Payments.Parameter.Identifier
    ) -> Bool {
        
        (try? value(forIdentifier: identifier)) != nil
    }
}

extension Payments.ParameterButton.Style: Decodable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        let string = try container.decode(String.self)
        
        switch string {
            
        case "red", "RED", "primary", "PRIMARY":
            self = .primary
            
        case "gray", "GRAY", "white", "WHITE", "secondary", "SECONDARY":
            self = .secondary
            
        default:
            throw Payments.Error.unsupported
        }
    }
}

extension PaymentParameterSubscriber {
    
    var description: String? {
        
        if let legalName {
            
            if let subscriptionPurpose {
                
                return legalName + "\n" + subscriptionPurpose
            }
            return legalName
            
        } else {
            
            return subscriptionPurpose
        }
    }
}

extension Payments.ParameterSelectBank.Option {
    
    var text: String {
          
          switch subtitle {
          case let .some(subtitle):
              return subtitle
          case .none:
              return name
          }
      }

}
