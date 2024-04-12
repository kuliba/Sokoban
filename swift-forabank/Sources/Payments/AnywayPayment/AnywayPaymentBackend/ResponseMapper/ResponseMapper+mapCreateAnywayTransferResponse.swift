//
//  ResponseMapper+mapCreateAnywayTransferResponse.swift
//
//
//  Created by Igor Malyarov on 26.03.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapCreateAnywayTransferResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<CreateAnywayTransferResponse> {
        
        map(data, httpURLResponse, mapOrThrow: CreateAnywayTransferResponse.init)
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse {
    
    init(_ data: ResponseMapper._Data) {
        
        self.init(
            additional: data.additionalList.map { .init($0) },
            amount: data.amount,
            creditAmount: data.creditAmount,
            currencyAmount: data.currencyAmount,
            currencyPayee: data.currencyPayee,
            currencyPayer: data.currencyPayer,
            currencyRate: data.currencyRate,
            debitAmount: data.debitAmount,
            documentStatus: .init(data.documentStatus),
            fee: data.fee,
            finalStep: data.finalStep,
            infoMessage: data.infoMessage,
            needMake: data.needMake ?? false,
            needOTP: data.needOTP ?? false,
            needSum: data.needSum,
            parametersForNextStep: data.parameterListForNextStep.compactMap { .init($0) },
            paymentOperationDetailID: data.paymentOperationDetailId,
            payeeName: data.payeeName,
            printFormType: data.printFormType,
            scenario: .init(data.scenario)
        )
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.Additional {
    
    init(_ additional: ResponseMapper._Data._Additional) {
        
        self.init(
            fieldName: additional.fieldName,
            fieldValue: additional.fieldValue,
            fieldTitle: additional.fieldTitle,
            recycle: additional.recycle ?? false,
            svgImage: additional.svgImage,
            typeIdParameterList: additional.typeIdParameterList
        )
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.AntiFraudScenario {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "OK":                 self = .ok
        case "SCOR_SUSPECT_FRAUD": self = .suspect
        default:                   return nil
        }
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.DocumentStatus {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "COMPLETE":    self = .complete
        case "IN_PROGRESS": self = .inProgress
        case "REJECTED":    self = .rejected
        default:            return nil
        }
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.Parameter {
    
    init?(_ parameter: ResponseMapper._Data._Parameter) {
        
        guard let dataType = DataType(parameter.dataType)
        else { return nil }
        
        self.init(
            content: parameter.content,
            dataDictionary: parameter.dataDictionary,
            dataDictionaryРarent: parameter.dataDictionaryРarent,
            dataType: dataType,
            group: parameter.group,
            id: parameter.id,
            inputFieldType: .init(parameter.inputFieldType),
            inputMask: parameter.inputMask,
            isPrint: parameter.isPrint ?? false,
            isRequired: parameter.isRequired ?? false,
            maxLength: parameter.maxLength,
            mask: parameter.mask,
            minLength: parameter.minLength,
            order: parameter.order,
            phoneBook: parameter.phoneBook ?? false,
            rawLength: parameter.rawLength,
            isReadOnly: parameter.readOnly ?? false,
            regExp: parameter.regExp,
            subGroup: parameter.subGroup,
            subTitle: parameter.subTitle,
            svgImage: parameter.svgImage,
            title: parameter.title,
            type: .init(parameter.type),
            viewType: .init(parameter.viewType)
        )
    }
}

extension ResponseMapper.CreateAnywayTransferResponse.Parameter.DataType {
    
    init?(_ string: String) {
        
        guard string != "%String"
        else { self = .string; return }
        
        guard let pairs = try? string.splitDataType(),
              !pairs.isEmpty
        else { return nil }
        
        self = .pairs(pairs.map { .init(key: $0.key, value: $0.value) })
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.Parameter.InputFieldType {
    
    init?(_ rawValue: String?) {
        
        switch rawValue {
        case "ACCOUNT":   self = .account
        case "ADDRESS":   self = .address
        case "AMOUNT":    self = .amount
        case "BANK":      self = .bank
        case "BIC":       self = .bic
        case "COUNTER":   self = .counter
        case "DATE":      self = .date
        case "INSURANCE": self = .insurance
        case "INN":       self = .inn
        case "NAME":      self = .name
        case "OKTMO":     self = .oktmo
        case "PENALTY":   self = .penalty
        case "PHONE":     self = .phone
        case "PURPOSE":   self = .purpose
        case "RECIPIENT": self = .recipient
        case "VIEW":      self = .view
        default:          return nil
        }
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.Parameter.FieldType {
    
    init(_ rawValue: ResponseMapper._Data._Parameter.FieldType) {
        
        switch rawValue {
        case .input:      self = .input
        case .select:     self = .select
        case .maskList:   self = .maskList
        }
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.Parameter.ViewType {
    
    init(_ rawValue: ResponseMapper._Data._Parameter.ViewType) {
        
        switch rawValue {
        case .constant: self = .constant
        case .input:    self = .input
        case .output:   self = .output
        }
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let additionalList: [_Additional]
        let amount: Decimal?
        let creditAmount: Decimal?
        let currencyAmount: String?
        let currencyPayee: String?
        let currencyPayer: String?
        let currencyRate: Decimal?
        let debitAmount: Decimal?
        let documentStatus: String? // enum!
        let fee: Decimal?
        let finalStep: Bool
        let infoMessage: String?
        let needMake: Bool?
        let needOTP: Bool?
        let needSum: Bool
        let parameterListForNextStep: [_Parameter]
        let paymentOperationDetailId: Int?
        let payeeName: String?
        let printFormType: String?
        let scenario: String?
    }
}

private extension ResponseMapper._Data {
    
    struct _Additional: Decodable {
        
        let fieldName: String
        let fieldValue: String
        let fieldTitle: String
        let recycle: Bool?
        let svgImage: String?
        let typeIdParameterList: String?
    }
    
    struct _Parameter: Decodable {
        
        let content: String?
        let dataDictionary: String?
        let dataDictionaryРarent: String?
        let dataType: String
        let group: String?
        let id: String
        let inputFieldType: String?
        let inputMask: String?
        let isPrint: Bool?
        let isRequired: Bool?
        let maxLength: Int?
        let mask: String?
        let minLength: Int?
        let order: Int?
        let phoneBook: Bool?
        let rawLength: Int
        let readOnly: Bool?
        let regExp: String
        let subGroup: String?
        let subTitle: String?
        let svgImage: String?
        let title: String
        let type: FieldType
        let viewType: ViewType
    }
}

private extension ResponseMapper._Data._Parameter {
    
    enum FieldType: String, Decodable {
        
        case input    = "Input"
        case select   = "Select"
        case maskList = "MaskList"
    }
    
    enum ViewType: String, Decodable {
        
        case constant = "CONSTANT"
        case input    = "INPUT"
        case output   = "OUTPUT"
    }
}
