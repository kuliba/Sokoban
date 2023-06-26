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
            let headerParameter = transportHeader(
                forPuref: Purefs.avtodorContract,
                title: "Автодор Платные дороги")
            
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
            
            let amountParameter: Payments.ParameterAmount = .avtodor(
                maxAmount: nil
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

private extension Payments.ParameterAmount {
    
    static func avtodor(
        maxAmount: Double?
    ) -> Self {
        
        return .init(
            value: nil,
            title: "Сумма платежа",
            currencySymbol: "RUB",
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
