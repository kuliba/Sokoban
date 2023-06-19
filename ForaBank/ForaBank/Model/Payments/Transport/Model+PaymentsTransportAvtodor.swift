//
//  Model+PaymentsTransportAvtodor.swift
//  ForaBank
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
            let contractLogo = operatorLogo(forPuref: Purefs.avtodorContract)
            let headerParameter = Payments.ParameterHeader(
                title: "Автодор Платные дороги",
                subtitle: nil,
                icon: .image(contractLogo ?? .empty)
            )
            
            // product
            let filter = ProductData.Filter.generalFrom
            let product = try firstProductToPayFrom(filter: filter)
            let productParameter = Payments.ParameterProduct(
                value: String(product.id),
                filter: filter,
                isEditable: true
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
            
            let puref = try parameters.value(forIdentifier: .operator)
            
            guard let operatorValue = dictionaryAnywayOperator(for: puref)
            else {
                throw Payments.Error.missingOperator(forCode: puref)
            }
            
            guard let parameterData = operatorValue.parameterList.first
            else {
                throw Payments.Error.missingParameterList(forCode: operatorValue.code)
            }
            
            // manual validation creation due to incorrect data
            // let pureInput = try paymentsParameterRepresentable(
            //     parameterData: parameterData
            // )
#warning("fix validation")
            let input = Payments.ParameterInput(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterDocument,
                title: parameterData.title,
                validator: .init(rules: [])
            )
            
            return .init(
                parameters: [input],
                front: .init(
                    visible: [input.id],
                    isCompleted: false
                ),
                back: .init(
                    stage: .remote(.start),
                    required: [input.id],
                    processed: nil
                )
            )
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    // MARK: - Process Remote Step
    
    func paymentsProcessRemoteStepAvtodor(
        _ operation: Payments.Operation,
        response: TransferAnywayResponseData
    ) async throws -> Payments.Operation.Step {
        
        let step = try await step(
            for: operation,
            with: response
        )
        
        var parameters = step.parameters
        
        if let amount = try? makeAvtodorAmount(with: step.parameters) {
            
            parameters.append(amount)
        }
        
        return Payments.Operation.Step(
            parameters: parameters,
            front: step.front,
            back: step.back
        )
    }
    
    // MARK: - Change Parameters Visibility and Order
    
    func paymentsProcessOperationResetVisibleAvtodor(
        _ operation: Payments.Operation
    ) async throws -> [Payments.Parameter.ID]? {
        
        guard operation.isConfirmCurrentStage else {
            return nil
        }
        
        let identifiers: [Payments.Parameter.Identifier] = [
            .header,
            .operator,
            .p1,
            .product,
            .sfpAmount,
            .code,
            .amount,
        ]
        
        return identifiers.map(\.rawValue)
    }
    
    // MARK: - Helpers
    
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

    // TODO: add tests
    func makeAvtodorAmount(
        with parameters: [PaymentsParameterRepresentable]
    ) throws -> Payments.ParameterAmount {
        
        let sum = try parameters.value(forId: "SumSTrs")

        let amount = Payments.ParameterAmount(
            value: sum,
            title: "Сумма платежа",
            currencySymbol: "RUB",
            validator: .init(minAmount: 1, maxAmount: nil)
        )

        return amount
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
}
