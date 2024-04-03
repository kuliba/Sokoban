//
//  CreateAnywayTransferResponse.swift
//
//
//  Created by Igor Malyarov on 26.03.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    public struct CreateAnywayTransferResponse: Equatable {
        
        public let additionals: [Additional]
        public let amount: Decimal?
        public let creditAmount: Decimal?
        public let currencyAmount: String?
        public let currencyPayee: String?
        public let currencyPayer: String?
        public let currencyRate: Decimal?
        public let debitAmount: Decimal?
        public let documentStatus: DocumentStatus?
        public let fee: Decimal?
        public let finalStep: Bool
        public let infoMessage: String?
        public let needMake: Bool
        public let needOTP: Bool
        public let needSum: Bool
        public let parametersForNextStep: [Parameter]
        public let paymentOperationDetailID: Int?
        public let payeeName: String?
        public let printFormType: String?
        public let scenario: AntiFraudScenario?
        
        public init(
            additionals: [Additional],
            amount: Decimal? = nil,
            creditAmount: Decimal? = nil,
            currencyAmount: String? = nil,
            currencyPayee: String? = nil,
            currencyPayer: String? = nil,
            currencyRate: Decimal? = nil,
            debitAmount: Decimal? = nil,
            documentStatus: DocumentStatus? = nil,
            fee: Decimal? = nil,
            finalStep: Bool,
            infoMessage: String? = nil,
            needMake: Bool,
            needOTP: Bool,
            needSum: Bool,
            parametersForNextStep: [Parameter],
            paymentOperationDetailID: Int? = nil,
            payeeName: String? = nil,
            printFormType: String? = nil,
            scenario: AntiFraudScenario? = nil
        ) {
            self.additionals = additionals
            self.amount = amount
            self.creditAmount = creditAmount
            self.currencyAmount = currencyAmount
            self.currencyPayee = currencyPayee
            self.currencyPayer = currencyPayer
            self.currencyRate = currencyRate
            self.debitAmount = debitAmount
            self.documentStatus = documentStatus
            self.fee = fee
            self.finalStep = finalStep
            self.infoMessage = infoMessage
            self.needMake = needMake
            self.needOTP = needOTP
            self.needSum = needSum
            self.parametersForNextStep = parametersForNextStep
            self.paymentOperationDetailID = paymentOperationDetailID
            self.payeeName = payeeName
            self.printFormType = printFormType
            self.scenario = scenario
        }
    }
}

extension ResponseMapper.CreateAnywayTransferResponse {
    
    public struct Additional: Equatable {
        
        public let fieldName: String
        public let fieldValue: String
        public let fieldTitle: String
        public let recycle: Bool
        public let svgImage: String?
        public let typeIdParameterList: String?
        
        public init(
            fieldName: String,
            fieldValue: String,
            fieldTitle: String,
            recycle: Bool,
            svgImage: String? = nil,
            typeIdParameterList: String? = nil
        ) {
            self.fieldName = fieldName
            self.fieldValue = fieldValue
            self.fieldTitle = fieldTitle
            self.recycle = recycle
            self.svgImage = svgImage
            self.typeIdParameterList = typeIdParameterList
        }
    }
    
    public enum AntiFraudScenario: Equatable {
        
        case ok, suspect
    }
    
    public enum DocumentStatus: Equatable {
        
        case complete, inProgress, rejected
    }
    
    public struct Parameter: Equatable {
        
        public let content: String?
        public let dataDictionary: String?
        public let dataDictionaryРarent: String?
        public let dataType: DataType?
        public let group: String?
        public let id: String
        public let inputFieldType: InputFieldType?
        public let inputMask: String?
        public let isPrint: Bool
        public let isRequired: Bool
        public let maxLength: Int?
        public let mask: String?
        public let minLength: Int?
        public let order: Int?
        public let phoneBook: Bool
        public let rawLength: Int
        public let isReadOnly: Bool
        public let regExp: String
        public let subGroup: String?
        public let subTitle: String?
        public let svgImage: String?
        public let title: String
        public let type: FieldType
        public let viewType: ViewType
        
        public init(
            content: String? = nil,
            dataDictionary: String? = nil,
            dataDictionaryРarent: String? = nil,
            dataType: DataType?,
            group: String? = nil,
            id: String,
            inputFieldType: InputFieldType?,
            inputMask: String? = nil,
            isPrint: Bool,
            isRequired: Bool,
            maxLength: Int? = nil,
            mask: String? = nil,
            minLength: Int? = nil,
            order: Int? = nil,
            phoneBook: Bool,
            rawLength: Int,
            isReadOnly: Bool,
            regExp: String,
            subGroup: String? = nil,
            subTitle: String? = nil,
            svgImage: String?,
            title: String,
            type: FieldType,
            viewType: ViewType
        ) {
            self.content = content
            self.dataDictionary = dataDictionary
            self.dataDictionaryРarent = dataDictionaryРarent
            self.dataType = dataType
            self.group = group
            self.id = id
            self.inputFieldType = inputFieldType
            self.inputMask = inputMask
            self.isPrint = isPrint
            self.isRequired = isRequired
            self.maxLength = maxLength
            self.mask = mask
            self.minLength = minLength
            self.order = order
            self.phoneBook = phoneBook
            self.rawLength = rawLength
            self.isReadOnly = isReadOnly
            self.regExp = regExp
            self.subGroup = subGroup
            self.subTitle = subTitle
            self.svgImage = svgImage
            self.title = title
            self.type = type
            self.viewType = viewType
        }
    }
}

extension ResponseMapper.CreateAnywayTransferResponse.Parameter {
    
    public enum DataType: Equatable {
        
        case string
        case pairs([Pairs])
        
        public struct Pairs: Equatable {
            
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

    public enum FieldType: Equatable {
        
        case input, select, maskList
    }
    
    public enum InputFieldType: Equatable {
        
        case account
        case address
        case amount
        case bank
        case bic
        case counter
        case date
        case insurance
        case inn
        case name
        case oktmo
        case penalty
        case phone
        case purpose
        case recipient
        case view
    }
    
    public enum ViewType: Equatable {
        
        case constant, input, output
    }
}
