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
            
            return .refresh
        }
        
        let detailPayerId = detail.payerCardId ?? detail.payerAccountId
        
        if template.parameterList.last?.payer?.productIdDescription != detailPayerId.description {
            
            return .refresh
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
                return .refresh
            }
            
            return .complete
            
        default:
            
            let inn = try? operation.parameters.value(forIdentifier: .requisitsInn)
            let kpp = try? operation.parameters.value(forIdentifier: .requisitsKpp)
            let accountNumber = try? operation.parameters.value(forIdentifier: .requisitsAccountNumber)
            let name = try? operation.parameters.value(forIdentifier: .requisitsName)
            let comment = try? operation.parameters.value(forIdentifier: .requisitsMessage)
            
            guard let payeeExternal = payload.payeeExternal else {
                return .idle
            }
            
            if payeeExternal.inn?.description != inn || payeeExternal.kpp != kpp || payeeExternal.accountNumber != accountNumber || payeeExternal.name != name || template.parameterList.first?.comment != comment {
                
                return .refresh
            } else {
                
                return .complete
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
                payerProductId: payerProductId,
                payeeProductId: payeeProductId,
                amount: amount
            )
            
            return templatePayment == meToMePayment ? .complete : .refresh
            
        default:
            return .idle
        }
    }
    
    fileprivate static func equalValuesInAnywayData(
        _ payload: TransferAnywayData,
        _ sfpRestrictedAdditional: [String],
        _ values: [String]
    ) -> TemplateButtonView.ViewModel.State {
        
        for additional in payload.additional.filter({ !$0.fieldname.contained(in: sfpRestrictedAdditional) }) {
            
            if additional.fieldvalue.contained(in: values) || additional.fieldvalue.isEmpty {
                
                continue
                
            } else {
                
                return .refresh
            }
        }
        
        return .complete
    }
    
    fileprivate static func handlePayloadWithAnywayData(
        _ model: Model,
        _ operation: (Payments.Operation),
        _ payload: TransferAnywayData
    ) -> TemplateButtonView.ViewModel.State {
        
        let additional = model.additionalTransferData(
            service: operation.service,
            operation: operation
        )
        
        guard let additional else {
            return .complete
        }
        
        let values = additional.map(\.fieldvalue)
        
        let sfpRestrictedAdditional = [
            Payments.Parameter.Identifier.sfpAmount.rawValue,
            Payments.Parameter.Identifier.code.rawValue,
            "CcyCode"
        ]
        
        return equalValuesInAnywayData(payload, sfpRestrictedAdditional, values)
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
        operationDetail: OperationDetailData,
        template: PaymentTemplateData
    ) -> [TransferData]? {
        
        let payerProductId = operationDetail.payerCardId ?? operationDetail.payerAccountId
        guard let templateParameterList = template.parameterList.last as? TransferGeneralData,
              let payeeProductId = templateParameterList.payeeInternal?.accountId ?? templateParameterList.payeeInternal?.cardId,
              let payee = model.allProducts.first(where: {$0.id == payeeProductId }),
              let payerData = model.allProducts.first(where: { $0.id == payerProductId }),
              let payer = TransferGeneralData.Payer(productData: payerData)
        else {
            return nil
        }
        
        return [TransferGeneralData(
            amount: Decimal(string: operationDetail.amount.description),
            check: false,
            comment: nil,
            currencyAmount: operationDetail.currencyAmount,
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
                    currencyAmount: operationDetail.currencyAmount,
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
                        currencyAmount: operationDetail.currencyAmount,
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
            )
            
            guard let additional else {
                return nil
            }
            
            return [
                TransferAnywayData(
                    amount: Decimal(string: operationDetail.amount.description),
                    check: false,
                    comment: operationDetail.comment,
                    currencyAmount: operationDetail.currencyAmount,
                    payer: operationDetail.payerTransferData,
                    additional: additional,
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
