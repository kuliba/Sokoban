//
//  Model+PaymentsMobileConnection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.02.2023.
//

import Foundation

extension Model {
    
    func paymentsProcessLocalStepMobileConnection(
        _ operation: Payments.Operation,
        for stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            let operatorParameter = Payments.ParameterOperator(
                operatorType: .mobileConnection
            )
            
            let headerParameter: Payments.ParameterHeader = parameterHeader(
                source: operation.source,
                header: .init(title: "Оплата мобильной связи")
            )
                
            let phoneParameterId = Payments.Parameter.Identifier.mobileConnectionPhone.rawValue
            let phoneParameter = Payments.ParameterInputPhone(
                .init(id: phoneParameterId, value: nil),
                title: "Номер телефона",
                countryCode: .russian
            )
            
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            let filter = ProductData.Filter.generalFrom
            
            guard let product = firstProduct(with: filter),
                  let currencySymbol = dictionaryCurrencySymbol(for: product.currency)
            else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            
            let productId = productWithSource(source: operation.source, productId: String(product.id))
            let productParameter = Payments.ParameterProduct(value: productId, filter: filter, isEditable: true)
            
            let amountParameter = Payments.ParameterAmount(
                value: nil,
                title: "Сумма перевода",
                currencySymbol: currencySymbol,
                transferButtonTitle: "Продолжить",
                validator: .init(
                    minAmount: 0.01,
                    maxAmount: product.balance
                ),
                info: .action(
                    title: "Возможна комиссия",
                    .name("ic24Info"),
                    .feeInfo
                )
            )
            
            return .init(
                parameters: [
                    operatorParameter,
                    headerParameter,
                    phoneParameter,
                    productParameter,
                    amountParameter,
                ],
                front: .init(
                    visible: [
                        headerParameter.id,
                        phoneParameter.id,
                        productParameter.id,
                        amountParameter.id,
                    ],
                    isCompleted: false
                ),
                back: .init(
                    stage: .remote(.start),
                    required: [
                        phoneParameter.id,
                        productParameter.id,
                        amountParameter.id,
                    ],
                    processed: nil)
            )
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsProcessRemoteStepMobileConnection(
        _ operation: Payments.Operation,
        response: TransferAnywayResponseData
    ) async throws -> Payments.Operation.Step {
        
        let next = try await paymentsTransferMobileConnectionStepParameters(
            parameters: operation.parameters,
            response: response
        )
        
        let duplicates = next
            .map { $0.parameter }
            .filter { operation.parametersIds.contains($0.id) }
        
        if !duplicates.isEmpty {
            LoggerAgent.shared.log(
                level: .error,
                category: .payments,
                message: "Anyway transfer response duplicates detected end removed: \(duplicates) from operation: \(operation.shortDescription)"
            )
        }
        
        // next parameters without duplicates
        var nextParameters = next.filter { !operation.parametersIds.contains($0.id) }
        
        let visible = try paymentsTransferMobileConnectionStepVisible(
            nextStepParameters: nextParameters,
            operationParameters: operation.parameters,
            response: response
        )
        let stepStage = try paymentsTransferMobileConnectionStepStage(
            operation,
            response: response
        )
        let required = try paymentsTransferMobileConnectionStepRequired(
            operation,
            visible: visible,
            nextStepParameters: nextParameters,
            operationParameters: operation.parameters
        )
        
        if response.scenario == .suspect {
            
            nextParameters.append(Payments.ParameterInfo(
                .init(id: Payments.Parameter.Identifier.sfpAntifraud.rawValue, value: "SUSPECT"),
                icon: .image(.parameterDocument),
                title: "Antifraud"
            ))
        }
        
        return Payments.Operation.Step(
            parameters: nextParameters,
            front: .init(
                visible: visible,
                isCompleted: false
            ),
            back: .init(
                stage: stepStage,
                required: required,
                processed: nil
            )
        )
    }
    
    func paymentsProcessRemoteMobileConnectionComplete(
        code: String,
        operation: Payments.Operation
    ) async throws -> Payments.Success {
        
        let response = try await paymentsTransferComplete(
            code: code
        )
        let operatorLogo = try operation.parameters.parameter(
            forIdentifier: .mobileConnectionOperatorLogo,
            as: Payments.ParameterOperatorLogo.self
        )

        let success = try Payments.Success(
            with: response,
            operation: operation,
            logoImage: .init(description: operatorLogo.svgImage),
            amountFormatter: amountFormatted(amount:productID:style:)
        )
        
        return success
    }
}

//MARK: - resets visible items and order

extension Model {
    
    func paymentsProcessOperationResetVisibleMobileConnection(
        _ operation: Payments.Operation
    ) async throws -> [Payments.Parameter.ID]? {
        
        guard operation.isConfirmCurrentStage else {
            return nil
        }

        let identifiers: [Payments.Parameter.Identifier] = [
            .header,
            .mobileConnectionPhone,
            .product,
            .mobileConnectionAmount,
            .fee,
            .code,
        ]
        
        return identifiers.map(\.rawValue)
    }
    
    func parameterHeader(
        source: Payments.Operation.Source?,
        header: Payments.ParameterHeader
    ) -> Payments.ParameterHeader {
        
        guard let source,
              let templateHeader = templateHeader(
            templates: self.paymentTemplates.value,
            source: source) else {
            return header
        }
            
        return templateHeader
    }
}
