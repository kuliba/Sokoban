//
//  Model+PaymentsTransportAvtodor.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.06.2023.
//

import Foundation

extension Model {
    
    // MARK: - Process Local Step
    
    func paymentsProcessLocalStepAvtodor(
        parameters: [PaymentsParameterRepresentable],
        for stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            
            // useless calls
            _ = try await isSingleService(Purefs.avtodorContract)
            _ = try await isSingleService(Purefs.avtodorTransponder)
            
            // header
            let headerParameter = transportHeader(
                forPuref: Purefs.avtodorContract,
                title: .avtodorGroupTitle)
            
            // product
            let (productParameter, _) = try productParameter(
                filter: .generalFrom
            )
            
            // black drop down
            let identifier = Payments.Parameter.Identifier.operator
            let contractIcon = icon(
                forPuref: Purefs.avtodorContract,
                fallback: "ic24FileHash"
            )
            let transponderIcon = icon(
                forPuref: Purefs.avtodorTransponder,
                fallback: "ic24Hash"
            )
            
            let selectParameter = Payments.ParameterSelectDropDownList(
                .init(id: identifier.rawValue, value: Purefs.avtodorContract),
                title: "Способ оплаты",
                options: [
                    .init(
                        id: Purefs.avtodorContract,
                        name: "По договору",
                        icon: contractIcon
                    ),
                    .init(
                        id: Purefs.avtodorTransponder,
                        name: "По транспондеру",
                        icon: transponderIcon
                    )
                ]
            )
            
            return .init(
                parameters: [headerParameter, productParameter, selectParameter],
                front: .init(
                    visible: [headerParameter.id, selectParameter.id],
                    isCompleted: true
                ),
                back: .init(
                    stage: .local,
                    required: [selectParameter.id],
                    processed: nil
                )
            )
            
        case 1:
            
            let inputParameterData = try firstParameterData(
                ofType: "Input",
                forIdentifier: .operator,
                from: parameters
            )
            
            // TODO: FIX validation
            // manual validation creation due to incorrect data
            // let pureInput = try paymentsParameterRepresentable(
            //     parameterData: parameterData
            // )
#warning("fix validation")
            let input = Payments.ParameterInput(
                .init(
                    id: inputParameterData.id,
                    value: inputParameterData.value
                ),
                icon: inputParameterData.iconData ?? .parameterDocument,
                title: inputParameterData.title,
                validator: .init(rules: [])
            )
            
            return .init(
                parameters: [input],
                front: .init(
                    visible: [input.id],
                    isCompleted: false
                ),
                back: .init(
                    stage: .local,
                    required: [input.id],
                    processed: nil
                )
            )
            
        case 2:
            
            let amountParameter = avtodorParameterAmount(
                parameters: parameters
            )
            
            return .init(
                parameters: [amountParameter],
                front: .init(
                    visible: [amountParameter.id],
                    isCompleted: false
                ),
                back: .init(
                    stage: .remote(.start),
                    required: [amountParameter.id],
                    processed: nil
                )
            )
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    // MARK: - Process Remote Step
    
    func paymentsProcessRemoteStepAvtodor(
        parameters: [PaymentsParameterRepresentable],
        process: [Payments.Parameter],
        isNewPayment: Bool
    ) async throws -> TransferAnywayResponseData {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let puref = try paymentsTransferAnywayPuref(parameters)
        let payer = try paymentsTransferAnywayPayer(parameters)
        let amount = try paymentsTransferAnywayAmount(parameters)
        let currency = try paymentsTransferAnywayCurrency(parameters)
        let comment = try paymentsTransferAnywayComment(parameters)
        
        let excludingParameters: [Payments.Parameter.Identifier] = [
            .amount,
            .code,
            .product,
            .`continue`,
            .header,
            .`operator`,
            .service,
            .category
        ]
        
        let additional = try paymentsTransferAvtodorAdditional(
            parameters,
            excluding: excludingParameters.map(\.rawValue)
        )

        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: isNewPayment, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await serverAgent.executeCommand(command: command)
    }
    
    // MARK: - Request Parameters
    
    func paymentsTransferAvtodorAdditional(
        _ parameters: [PaymentsParameterRepresentable],
        excluding excludingParameterIDs: [String]
    ) throws -> [TransferAnywayData.Additional] {
        
        return parameters
            .filter { !excludingParameterIDs.contains($0.id) }
            .enumerated()
            .compactMap { (index, parameter) -> TransferAnywayData.Additional? in
                
                guard let parameterValue = parameter.value
                else { return nil }
                
                return .init(
                    fieldid: index + 1,
                    fieldname: parameter.id,
                    fieldvalue: parameterValue
                )
            }
    }
    
    // MARK: - Change Parameters Visibility and Order
    
    func paymentsProcessOperationResetVisibleAvtodor(
        _ operation: Payments.Operation
    ) async throws -> [Payments.Parameter.ID]? {
        
        let identifiers: [Payments.Parameter.Identifier]?
        
        switch operation.steps.last?.back.stage {
            
        case .remote(.start):
            identifiers = [
                .header,
                .operator,
                .p1,
                .product,
                .amount,
            ]
            
        case .remote(.confirm):
            identifiers = [
                .header,
                .operator,
                .p1,
                .product,
                .sfpAmount,
                .code,
                .amount,
            ]
            
        default:
            identifiers = nil
        }
        
        return identifiers?.map(\.rawValue)
    }
    
    // MARK: - Helpers
    
    func productParameter(
        filter: ProductData.Filter
    ) throws -> (
        productParameter: Payments.ParameterProduct,
        balance: Double?
    ) {
        
        let product = try firstProductToPayFrom(filter: filter)
        let productParameter = Payments.ParameterProduct(
            value: String(product.id),
            filter: filter,
            isEditable: true
        )
        let balance = product.balance
        
        return (productParameter, balance)
    }
    
    func firstProductToPayFrom(
        filter: ProductData.Filter
    ) throws -> ProductData {
        
        guard let product = firstProduct(with: filter)
        else {
            let productParameterId = Payments.Parameter.Identifier.product
            throw Payments.Error.unableCreateRepresentable(productParameterId.rawValue)
        }
        
        return product
    }

    func icon(
        forPuref puref: String,
        fallback iconName: String
    ) -> Payments.ParameterSelectDropDownList.Option.Icon {
        
        guard let imageData = operatorIconData(forPuref: puref)
        else { return .name(iconName) }
        
        return .image(imageData)
    }
    
    func operatorIconData(
        forPuref puref: String
    ) -> ImageData? {
        
        dictionaryAnywayOperator(for: puref)?.parameterList.first?.iconData
    }
    
    func operatorLogo(
        forPuref puref: String
    ) -> ImageData? {
        
        dictionaryAnywayOperator(for: puref)?.logotypeList.first?.iconData
    }
    
    func firstParameterData(
        ofType type: String?,
        forIdentifier identifier: Payments.Parameter.Identifier,
        from parameters: [PaymentsParameterRepresentable]
    ) throws -> ParameterData {
        
        let data = try parameterData(
            ofType: type,
            forIdentifier: identifier,
            from: parameters
        )
        
        guard let parameterData = data.first
        else {
            throw Payments.Error.emptyParameterList(forType: type)
        }
        
        return parameterData
    }
    
    func parameterData(
        ofType type: String?,
        forIdentifier identifier: Payments.Parameter.Identifier,
        from parameters: [PaymentsParameterRepresentable]
    ) throws -> [ParameterData] {
        
        let puref = try parameters.value(forIdentifier: .operator)
        
        guard let operatorValue = dictionaryAnywayOperator(for: puref)
        else {
            throw Payments.Error.missingOperator(forCode: puref)
        }

        return operatorValue.parameterList.filter { $0.type == type }
    }
}

extension Model {
    
    func avtodorParameterAmount(
        parameters: [PaymentsParameterRepresentable]
    ) -> Payments.ParameterAmount {
        
        let currencySymbol: String
        let maxAmount: Double?
        
        if
            let productId = try? parameters.parameter(
                forIdentifier: Payments.Parameter.Identifier.product,
                as: Payments.ParameterProduct.self
            ).productId,
            let product: ProductData = product(productId: productId) {
            
            currencySymbol = dictionaryCurrencySymbol(for: product.currency) ?? "₽"
            maxAmount = product.balance
            
        } else {
            
            currencySymbol = "₽"
            maxAmount = nil
        }
        
        return .init(
            value: nil,
            title: "Сумма платежа",
            currencySymbol: currencySymbol,
            transferButtonTitle: "Продолжить",
            validator: .init(
                minAmount: 0.01,
                maxAmount: maxAmount
            ),
            info: .action(
                title: "Возможна комиссия",
                .name("ic24Info"),
                .feeInfo
            )
        )
    }
}
