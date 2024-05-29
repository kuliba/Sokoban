//
//  AnywayPaymentUpdate+ext.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import AnywayPaymentBackend
import AnywayPaymentCore
import AnywayPaymentDomain
import RemoteServices

public extension AnywayPaymentUpdate {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            details: .init(response),
            fields: response.additional.map { .init($0) },
            parameters: response.parametersForNextStep.map { .init($0) }
        )
    }
}

private extension AnywayPaymentUpdate.Details {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            amounts: .init(response),
            control: .init(response),
            info: .init(response)
        )
    }
}

private extension AnywayPaymentUpdate.Details.Amounts {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            amount: response.amount,
            creditAmount: response.creditAmount,
            currencyAmount: response.currencyAmount,
            currencyPayee: response.currencyPayee,
            currencyPayer: response.currencyPayer,
            currencyRate: response.currencyRate,
            debitAmount: response.debitAmount,
            fee: response.fee
        )
    }
}

private extension AnywayPaymentUpdate.Details.Control {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            isFinalStep: response.finalStep,
            isFraudSuspected: response.scenario == .suspect,
            needMake: response.needMake,
            needOTP: response.needOTP,
            needSum: response.needSum
        )
    }
}

private extension AnywayPaymentUpdate.Details.Info {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            documentStatus: response.documentStatus.map { .init($0) },
            infoMessage: response.infoMessage,
            payeeName: response.payeeName,
            paymentOperationDetailID: response.paymentOperationDetailID,
            printFormType: response.printFormType
        )
    }
}

private extension AnywayPaymentUpdate.Details.Info.DocumentStatus {
    
    init(_ documentStatus: ResponseMapper.CreateAnywayTransferResponse.DocumentStatus) {
        
        switch documentStatus {
        case .complete:   self = .complete
        case .inProgress: self = .inProgress
        case .rejected:   self = .rejected
        }
    }
}

private extension AnywayPaymentUpdate.Field {
    
    init(_ additional: ResponseMapper.CreateAnywayTransferResponse.Additional) {
        
        self.init(
            name: additional.fieldName,
            value: additional.fieldValue,
            title: additional.fieldTitle,
            md5Hash: additional.md5hash,
            recycle: additional.recycle,
            svgImage: additional.svgImage,
            typeIdParameterList: additional.typeIdParameterList
        )
    }
}

private extension AnywayPaymentUpdate.Parameter {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            field: .init(parameter),
            masking: .init(parameter),
            validation: .init(parameter),
            uiAttributes: .init(parameter)
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.Field {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            content: parameter.content,
            dataDictionary: parameter.dataDictionary,
            dataDictionaryРarent: parameter.dataDictionaryРarent,
            id: parameter.id
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.Masking {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            inputMask: parameter.inputMask,
            mask: parameter.mask
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.Validation {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            isRequired: parameter.isRequired,
            maxLength: parameter.maxLength,
            minLength: parameter.minLength,
            rawLength: parameter.rawLength,
            regExp: parameter.regExp
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            dataType: .init(parameter.dataType),
            group: parameter.group,
            inputFieldType: parameter.inputFieldType.map { .init($0) },
            isPrint: parameter.isPrint,
            order: parameter.order,
            phoneBook: parameter.phoneBook,
            isReadOnly: parameter.isReadOnly,
            subGroup: parameter.subGroup,
            subTitle: parameter.subTitle,
            svgImage: parameter.svgImage,
            title: parameter.title,
            type: .init(parameter.type),
            viewType: .init(parameter.viewType)
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.DataType {
    
    init(_ dataType: ResponseMapper.CreateAnywayTransferResponse.Parameter.DataType) {
        
        switch dataType {
        case ._backendReserved:
            self = ._backendReserved
            
        case .number:
            self = .number
            
        case let .pairs(pair, pairs):
            self = .pairs(pair.pair, pairs.map(\.pair))

        case .string:
            self = .string
        }
    }
}

private extension ResponseMapper.CreateAnywayTransferResponse.Parameter.DataType.Pair {
    
    var pair: AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair {
        
        .init(key: key, value: value)
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.FieldType {
    
    init(_ type: ResponseMapper.CreateAnywayTransferResponse.Parameter.FieldType) {
        
        switch type {
        case .input:    self = .input
        case .select:   self = .select
        case .maskList: self = .maskList
        case .missing:  self = .missing
        }
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType {
    
    init(_ type: ResponseMapper.CreateAnywayTransferResponse.Parameter.InputFieldType) {
        
        switch type {
        case .account:   self = .account
        case .address:   self = .address
        case .amount:    self = .amount
        case .bank:      self = .bank
        case .bic:       self = .bic
        case .counter:   self = .counter
        case .date:      self = .date
        case .inn:       self = .inn
        case .insurance: self = .insurance
        case .name:      self = .name
        case .oktmo:     self = .oktmo
        case .penalty:   self = .penalty
        case .phone:     self = .phone
        case .purpose:   self = .purpose
        case .recipient: self = .recipient
        case .view:      self = .view
        }
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.ViewType {
    
    init(_ type: ResponseMapper.CreateAnywayTransferResponse.Parameter.ViewType) {
        
        switch type {
        case .constant: self = .constant
        case .input:    self = .input
        case .output:   self = .output
        }
    }
}
