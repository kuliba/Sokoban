//
//  AnywayPaymentUpdate.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import Foundation

public struct AnywayPaymentUpdate: Equatable {
    
    public let details: Details
    public let fields: [Field]
    public let parameters: [Parameter]
    
    public init(
        details: Details,
        fields: [Field],
        parameters: [Parameter]
    ) {
        self.details = details
        self.fields = fields
        self.parameters = parameters
    }
}

extension AnywayPaymentUpdate {
    
    public struct Details: Equatable {
        
        public let amounts: Amounts
        public let control: Control
        public let info: Info
        
        public init(
            amounts: Amounts,
            control: Control,
            info: Info
        ) {
            self.amounts = amounts
            self.control = control
            self.info = info
        }
    }
    
    public struct Field: Equatable {
        
        public let name: String
        public let value: String
        public let title: String
        @available(*, deprecated, message: "not used according to analytics")
        public let recycle: Bool
        public let svgImage: String?
        public let typeIdParameterList: String?
        
        public init(
            name: String,
            value: String,
            title: String,
            recycle: Bool,
            svgImage: String?,
            typeIdParameterList: String?
        ) {
            self.name = name
            self.value = value
            self.title = title
            self.recycle = recycle
            self.svgImage = svgImage
            self.typeIdParameterList = typeIdParameterList
        }
    }
    
    public struct Parameter: Equatable {
        
        public let field: Field
        public let masking: Masking
        public let validation: Validation
        public let uiAttributes: UIAttributes
        
        public init(
            field: Field,
            masking: Masking,
            validation: Validation,
            uiAttributes: UIAttributes
        ) {
            self.field = field
            self.masking = masking
            self.validation = validation
            self.uiAttributes = uiAttributes
        }
    }
}

extension AnywayPaymentUpdate.Details {
    
    public struct Amounts: Equatable {
        
        public let amount: Decimal?
        public let creditAmount: Decimal?
        public let currencyAmount: String?
        public let currencyPayee: String?
        public let currencyPayer: String?
        public let currencyRate: Decimal?
        public let debitAmount: Decimal?
        public let fee: Decimal?
        
        public init(
            amount: Decimal?,
            creditAmount: Decimal?,
            currencyAmount: String?,
            currencyPayee: String?,
            currencyPayer: String?,
            currencyRate: Decimal?,
            debitAmount: Decimal?,
            fee: Decimal?
        ) {
            self.amount = amount
            self.creditAmount = creditAmount
            self.currencyAmount = currencyAmount
            self.currencyPayee = currencyPayee
            self.currencyPayer = currencyPayer
            self.currencyRate = currencyRate
            self.debitAmount = debitAmount
            self.fee = fee
        }
    }
    
    public struct Control: Equatable {
        
        public let isFinalStep: Bool
        public let isFraudSuspected: Bool
        public let needMake: Bool
        public let needOTP: Bool
        public let needSum: Bool
        
        public init(
            isFinalStep: Bool,
            isFraudSuspected: Bool,
            needMake: Bool,
            needOTP: Bool,
            needSum: Bool
        ) {
            self.isFinalStep = isFinalStep
            self.isFraudSuspected = isFraudSuspected
            self.needMake = needMake
            self.needOTP = needOTP
            self.needSum = needSum
        }
    }
    
    public struct Info: Equatable {
        
        public let documentStatus: DocumentStatus?
        public let infoMessage: String?
        public let payeeName: String?
        public let paymentOperationDetailID: Int?
        public let printFormType: String?
        
        public init(
            documentStatus: DocumentStatus?,
            infoMessage: String?,
            payeeName: String?,
            paymentOperationDetailID: Int?,
            printFormType: String?
        ) {
            self.documentStatus = documentStatus
            self.infoMessage = infoMessage
            self.payeeName = payeeName
            self.paymentOperationDetailID = paymentOperationDetailID
            self.printFormType = printFormType
        }
    }
}

public extension AnywayPaymentUpdate.Details.Info {
    
    enum DocumentStatus: Equatable {
        
        case complete, inProgress, rejected
    }
}

extension AnywayPaymentUpdate.Parameter {
    
    public struct Field: Equatable {
        
        @available(*, deprecated, message: "not used according to analytics")
        public let content: String?
        @available(*, deprecated, message: "not used according to analytics")
        public let dataDictionary: String?
        @available(*, deprecated, message: "not used according to analytics")
        public let dataDictionaryРarent: String?
        public let id: String
        
        public init(
            content: String?,
            dataDictionary: String?,
            dataDictionaryРarent: String?,
            id: String
        ) {
            self.content = content
            self.dataDictionary = dataDictionary
            self.dataDictionaryРarent = dataDictionaryРarent
            self.id = id
        }
    }
    
    public struct Masking: Equatable {
        
        public let inputMask: String?
        public let mask: String?
        
        public init(
            inputMask: String?,
            mask: String?
        ) {
            self.inputMask = inputMask
            self.mask = mask
        }
    }
    
    public struct Validation: Equatable {
        
        @available(*, deprecated, message: "not used according to analytics")
        public let isRequired: Bool
        public let maxLength: Int?
        public let minLength: Int?
        @available(*, deprecated, message: "not used according to analytics")
        public let rawLength: Int // not used
        public let regExp: String
        
        public init(
            isRequired: Bool,
            maxLength: Int?,
            minLength: Int?,
            rawLength: Int,
            regExp: String
        ) {
            self.isRequired = isRequired
            self.maxLength = maxLength
            self.minLength = minLength
            self.rawLength = rawLength
            self.regExp = regExp
        }
    }
    
    public struct UIAttributes: Equatable {
        
        public let dataType: DataType // not used for `viewType: ViewType = .input` https://shorturl.at/hnrE1
        public let group: String?
        @available(*, deprecated, message: "not used according to analytics")
        public let inputFieldType: InputFieldType?
        public let isPrint: Bool // not used for `type: FieldType = .input`
        @available(*, deprecated, message: "not used according to analytics")
        public let order: Int? // not used https://shorturl.at/guIJ8
        public let phoneBook: Bool
        public let isReadOnly: Bool
        public let subGroup: String?
        public let subTitle: String?
        public let svgImage: String?
        public let title: String
        public let type: FieldType
        public let viewType: ViewType
        
        public init(
            dataType: DataType,
            group: String?,
            inputFieldType: InputFieldType?,
            isPrint: Bool,
            order: Int?,
            phoneBook: Bool,
            isReadOnly: Bool,
            subGroup: String?,
            subTitle: String?,
            svgImage: String?,
            title: String,
            type: FieldType,
            viewType: ViewType
        ) {
            self.dataType = dataType
            self.group = group
            self.inputFieldType = inputFieldType
            self.isPrint = isPrint
            self.order = order
            self.phoneBook = phoneBook
            self.isReadOnly = isReadOnly
            self.subGroup = subGroup
            self.subTitle = subTitle
            self.svgImage = svgImage
            self.title = title
            self.type = type
            self.viewType = viewType
        }
    }
}

public extension AnywayPaymentUpdate.Parameter.UIAttributes {
    
    enum DataType: Equatable {
        
        case string
        case pairs([Pair])
        
        public struct Pair: Equatable {
            
            public let key: String
            public let value: String
            
            public init(
                key: String,
                value: String
            ) {
                self.key = key
                self.value = value
            }
        }
    }

    enum FieldType: Equatable {
        
        case input, select, maskList
    }
    
    enum InputFieldType: Equatable {
        
        case account
        case address
        case amount
        case bank
        case bic
        case counter
        case date
        case inn
        case insurance
        case name
        case oktmo
        case penalty
        case phone
        case purpose
        case recipient
        case view
    }
    
    enum ViewType: Equatable {
        
        case constant, input, output
    }
}
