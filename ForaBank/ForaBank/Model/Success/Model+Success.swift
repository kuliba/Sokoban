//
//  Model+Success.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 11.08.2023.
//

import Foundation

enum TemplateButton {}

extension TemplateButton {
    
    static func templateButtonState(
        model: Model,
        template: PaymentTemplateData,
        operation: Payments.Operation?,
        meToMePayment: MeToMePayment?,
        detail: OperationDetailData
    ) -> TemplateButtonView.ViewModel.State {
        
        switch operation {
        case let .some(operation):
            return templateButtonStateWithOperation(
                model: model,
                template: template,
                operation: operation,
                detail: detail
            )
            
        default:
            return templateButtonStateWithMeToMePayment(
                template: template,
                meToMePayment: meToMePayment
            )
        }
    }
    
    static func templateButtonStateWithOperation(
        model: Model,
        template: PaymentTemplateData,
        operation: Payments.Operation,
        detail: OperationDetailData
    ) -> TemplateButtonView.ViewModel.State {
        
        if let amountTemplate = template.amount?.description,
           let amount = Double(amountTemplate),
           detail.amount.description != amount.description {
            
            return .refresh(templateId: template.id)
        }
        
        let detailPayerId = detail.payerCardId ?? detail.payerAccountId
        
        if template.parameterList.last?.payer?.productIdDescription != detailPayerId.description {
            
            return .refresh(templateId: template.id)
        }
        
        switch template.parameterList.last {
        case let payload as TransferGeneralData:
            
            return handlePayloadWithGeneralData(
                operation,
                template,
                payload
            )
            
        case let payload as TransferAnywayData:
            return handlePayloadWithAnywayData(
                template.id,
                model,
                operation,
                payload
            )
            
        default:
            return .idle
        }
    }
    
    fileprivate static func handlePayloadWithGeneralData(
        _ operation: Payments.Operation,
        _ template: PaymentTemplateData,
        _ payload: TransferGeneralData
    ) -> TemplateButtonView.ViewModel.State {
        
        switch operation.service {
        case .toAnotherCard:
            let anotherCard = try? operation.parameters.value(forIdentifier: .productTemplate)
            
            guard let generalData = template.parameterList.last as? TransferGeneralData,
                  let payeeInternalId = generalData.payeeInternal?.cardId ?? generalData.payeeInternal?.accountId,
                  anotherCard?.digits == payeeInternalId.description
            else {
                return .refresh(templateId: template.id)
            }
            
            return .complete(templateId: template.id)
            
        default:
            
            let inn = try? operation.parameters.value(forIdentifier: .requisitsInn)
            let kpp = try? operation.parameters.value(forIdentifier: .requisitsKpp)
            let accountNumber = try? operation.parameters.value(forIdentifier: .requisitsAccountNumber)
            let name = try? operation.parameters.value(forIdentifier: .requisitsName)
            let companyName = try? operation.parameters.value(forIdentifier: .requisitsCompanyName)
            let comment = try? operation.parameters.value(forIdentifier: .requisitsMessage)
            let bankBic = try? operation.parameters.value(forIdentifier: .requisitsBankBic)
            
            guard let payeeExternal = payload.payeeExternal else {
                return .idle
            }
            
            let external = TransferGeneralData.PayeeExternal(
                inn: inn,
                kpp: kpp,
                accountId: nil,
                accountNumber: accountNumber ?? "",
                bankBIC: bankBic,
                cardId: nil,
                cardNumber: nil,
                compilerStatus: nil,
                date: nil,
                name: name ?? companyName ?? "",
                tax: nil
            )
            
            if payeeExternal != external, template.parameterList.first?.comment != comment {
                
                return .refresh(templateId: template.id)
                
            } else {
                
                return .complete(templateId: template.id)
            }
        }
    }
    
    static func templateButtonStateWithMeToMePayment(
        template: PaymentTemplateData,
        meToMePayment: MeToMePayment?
    ) -> TemplateButtonView.ViewModel.State {
        
        guard let meToMePayment else {
            return .idle
        }
        
        switch template.parameterList.last {
        case let payload as TransferGeneralData:
            
            guard let payeeProductId = payload.payeeInternal?.cardId ?? payload.payeeInternal?.accountId,
                  let amountDescription = payload.amount?.description,
                  let amount = Double(amountDescription),
                  let payerProductId = payload.payer?.cardId ?? payload.payer?.accountId else {
                
                return .idle
            }
            
            let templatePayment = MeToMePayment(
                templateId: meToMePayment.templateId,
                payerProductId: payerProductId,
                payeeProductId: payeeProductId,
                amount: amount
            )
            
            return templatePayment == meToMePayment ? .complete(templateId: template.id) : .refresh(templateId: template.id)
            
        default:
            return .idle
        }
    }
    
    fileprivate static func equalValuesInAnywayData(
        _ templateId: Int,
        _ payload: TransferAnywayData,
        _ sfpRestrictedAdditional: [String],
        _ values: [String]
    ) -> TemplateButtonView.ViewModel.State {
        
        let payloadParameters = payload.additional
            .filter({ !$0.fieldname.contained(in: sfpRestrictedAdditional) })
            .filter({ !$0.fieldname.contained(in: Payments.Parameter.systemIdentifiers.map({ $0.rawValue })) })
        
        for additional in payloadParameters {
            
            if additional.fieldvalue.contained(in: values) || additional.fieldvalue.isEmpty {
                
                continue
                
            } else {
                
                return .refresh(templateId: templateId)
            }
        }
        
        return .complete(templateId: templateId)
    }
    
    fileprivate static func handlePayloadWithAnywayData(
        _ templateId: Int,
        _ model: Model,
        _ operation: (Payments.Operation),
        _ payload: TransferAnywayData
    ) -> TemplateButtonView.ViewModel.State {
        
        let additional = model.additionalTransferData(
            service: operation.service,
            operation: operation
        )
        
        guard let additional else {
            return .complete(templateId: templateId)
        }
        
        let values = additional
            .filter({ !$0.fieldname.contained(in: Payments.Parameter.systemIdentifiers.map({ $0.rawValue })) })
            .map(\.fieldvalue)
        
        let restrictedAdditional = [
            Payments.Parameter.Identifier.sfpAmount.rawValue,
            Payments.Parameter.Identifier.code.rawValue,
            Payments.Parameter.Identifier.countryTransferNumber.rawValue,
            Payments.Parameter.Identifier.countryPhone.rawValue,
            "CcyCode",
            "a3_PenaltyList_1_2"
        ]
        
        return equalValuesInAnywayData(templateId, payload, restrictedAdditional, values)
    }
    
    static func parametersOperation(
        service: Payments.Service?,
        operation: Payments.Operation
    ) -> (parameters: [PaymentsParameterRepresentable], processed: [Payments.Parameter]?) {
        
        let lastStep = operation.isLastProcessStep
        let parameters = operation.parameters
        
        guard let processed = lastStep?.back.processed else {
            return (parameters, nil)
        }
        
        return (parameters, processed)
    }
    
    static func createMe2MeParameterList(
        model: Model,
        operationDetail: OperationDetailData
    ) -> [TransferData]? {
        
        let payerProductId = operationDetail.payerProductId
        let payeeProductId = operationDetail.payeeProductId
        
        guard let payee = model.allProducts.first(where: {$0.id == payeeProductId }),
              let payerData = model.allProducts.first(where: { $0.id == payerProductId }),
              let payer = TransferGeneralData.Payer(productData: payerData)
        else {
            return nil
        }
        
        return [TransferGeneralData(
            amount: Decimal(string: operationDetail.amount.description),
            check: false,
            comment: nil,
            currencyAmount: operationDetail.currencyAmount ?? "",
            payer: payer,
            payeeExternal: nil,
            payeeInternal: .init(productData: payee)
        )]
    }
    
    static func templateParameterList(
        model: Model,
        operationDetail: OperationDetailData,
        operation: Payments.Operation?
    ) -> [TransferData]? {
        
        switch operation?.service {
        case .toAnotherCard:
            return [
                TransferGeneralData(
                    amount: Decimal(string: operationDetail.amount.description),
                    check: false,
                    comment: nil,
                    currencyAmount: operationDetail.currencyAmount ?? "",
                    payer: operationDetail.payerTransferData,
                    payeeExternal: nil,
                    payeeInternal: operationDetail.payeeInternal
                )
            ]
        case .requisites:
            guard let payeeExternal = operationDetail.payeeExternal else {
                return nil
            }
            
            return operationDetail.payeeExternal.map { payeeExternal in
                
                [
                    TransferGeneralData(
                        amount: Decimal(string: operationDetail.amount.description),
                        check: false,
                        comment: operationDetail.comment,
                        currencyAmount: operationDetail.currencyAmount ?? "",
                        payer: operationDetail.payerTransferData,
                        payeeExternal: payeeExternal,
                        payeeInternal: nil
                    )
                ]
            }

        default:
            guard let operation else {
                return nil
            }
            
            let additional = model.additionalTransferData(
                service: operation.service,
                operation: operation
            )?.filter({ !$0.fieldname.contained(in: Payments.Parameter.systemIdentifiers.map({ $0.rawValue })) })
            
            guard let additional else {
                return nil
            }
            
            let mobileAdditional = [TransferAnywayData.Additional(
                fieldid: 1,
                fieldname: "a3_NUMBER_1_2",
                fieldvalue: operationDetail.payeePhone ?? ""
            )]
            
            return [
                TransferAnywayData(
                    amount: Decimal(string: operationDetail.amount.description),
                    check: false,
                    comment: operationDetail.comment,
                    currencyAmount: operationDetail.currencyAmount ?? "",
                    payer: operationDetail.payerTransferData,
                    additional: operation.service != .mobileConnection ? additional : mobileAdditional,
                    puref: operationDetail.puref
                )
            ]
        }
    }
}

extension Model {
    
    func additionalTransferData(
        service: Payments.Service?,
        operation: Payments.Operation
    ) -> [TransferAnywayData.Additional]? {
        
        let (parameters, processed) = TemplateButton.parametersOperation(
            service: service,
            operation: operation
        )
        
        switch service {
        case .abroad:
            return try? paymentsTransferAnywayAbroadAdditional(
                parameters,
                restrictedParameters: restrictedParametersAbroad
            )
            
        case .sfp:
            guard let processed else {
                return nil
            }
            
            return try? paymentsTransferSFPAdditional(
                processed,
                allParameters: parameters
            )
            
        case .transport,
                .requisites,
                .avtodor,
                .fms,
                .fns,
                .fssp,
                .gibdd,
                .internetTV,
                .utility,
                .mobileConnection:
            
            return try? paymentsTransferPaymentsServicesAdditional(
                parameters,
                excludingParameters: []
            )
            
        default:
            return nil
        }
    }
}
