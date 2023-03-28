//
//  Model+PaymentsTransferMobileConnection.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.02.2023.
//

import Foundation

// MARK: - Request

extension Model {
    
    func paymentsTransferMobileConnectionProcess(
        parameters: [PaymentsParameterRepresentable],
        process: [Payments.Parameter]
    ) async throws -> TransferResponseData {
        
        let getPhoneInfoPayload = try await getPhoneInfoPayload(
            parameters: parameters
        )

        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let anywayTransfer = try createAnywayTransfer(
            token: token,
            getPhoneInfoPayload: getPhoneInfoPayload,
            parameters: parameters
        )
        
        return try await serverAgent.executeCommand(command: anywayTransfer)
    }
    
    func getPhoneInfoPayload(
        parameters: [PaymentsParameterRepresentable]
    ) async throws -> [DaDataPhoneData] {
        
        guard let token = token else {
            throw Payments.Error.notAuthorized
        }
        
        let getPhoneInfo = try await getPhoneInfo(
            token: token,
            parameters: parameters
        )
        
        let getPhoneInfoPayload = try await serverAgent.executeCommand(
            command: getPhoneInfo
        )
        
        return getPhoneInfoPayload
    }
}

// MARK: - Step

extension Model {
    
    func paymentsTransferMobileConnectionStepParameters(
        parameters: [PaymentsParameterRepresentable],
        response: TransferAnywayResponseData
    ) async throws -> [PaymentsParameterRepresentable] {
        
        let group = Payments.Parameter.Group(id: UUID().uuidString, type: .info)

        var result = [PaymentsParameterRepresentable]()
        
        if let amountValue = response.debitAmount,
           let amountFormatted = paymentsAmountFormatted(amount: amountValue, parameters: parameters) {
            let amountParameterId = Payments.Parameter.Identifier.mobileConnectionAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: "Сумма перевода", placement: .feed, group: group)
            
            result.append(amountParameter)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .init(named: "ic24PercentCommission") ?? .parameterDocument,
                title: "Комиссия", placement: .feed, group: group)
            
            result.append(feeParameter)
        }
        
        /// inject `ParameterOperatorLogo`
        // less than beautiful, but anyway expected
        // to be refactored with new system: receiving steps from backend
        let parameterOperatorLogo = try await getParameterOperatorLogo(
            parameters: parameters
        )
        result.append(parameterOperatorLogo)
        
        result.append(Payments.ParameterCode.regular)
        
        return result
    }
    
    func paymentsTransferMobileConnectionStepVisible(
        nextStepParameters: [PaymentsParameterRepresentable],
        operationParameters: [PaymentsParameterRepresentable],
        response: TransferAnywayResponseData
    ) throws -> [Payments.Parameter.ID] {
        
        var result = [Payments.Parameter.ID]()
        
        let nextStepParametersIDs = nextStepParameters.map(\.id)
        result.append(contentsOf: nextStepParametersIDs)
        
        if response.needSum == true {
            
            let operationParametersIds = operationParameters.map(\.id)
            let allParametersIDs = operationParametersIds + nextStepParametersIDs
            
            let productParameterID = Payments.Parameter.Identifier.product.rawValue
            
            guard allParametersIDs.contains(productParameterID)
            else {
                throw Payments.Error.missingParameter(productParameterID)
            }
            
            result.append(productParameterID)
        }
        
        return result
    }
    
    func paymentsTransferMobileConnectionStepStage(
        _ operation: Payments.Operation,
        response: TransferAnywayResponseData
    ) throws -> Payments.Operation.Stage {
        
        if response.finalStep {
            
            return .remote(.confirm)
            
        } else {
            
            let operationStepsStages = operation.steps.map(\.back.stage)
            
            if operationStepsStages.isEmpty {
                return .remote(.start)
            } else {
                return .remote(.next)
            }
        }
    }
    
    func paymentsTransferMobileConnectionStepRequired(
        _ operation: Payments.Operation,
        visible: [Payments.Parameter.ID],
        nextStepParameters: [PaymentsParameterRepresentable],
        operationParameters: [PaymentsParameterRepresentable]
    ) throws -> [Payments.Parameter.ID] {
        
        try paymentsTransferStepRequired(
            operation,
            visible: visible,
            nextStepParameters: nextStepParameters,
            operationParameters: operationParameters,
            restrictedParameters: []
        )
    }
}

// MARK: Request Parameters

extension Model {
    
    func paymentsTransferMobileConnectionPuref(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        try paymentsTransferPuref(parameters)
    }
    
    func paymentsTransferMobileConnectionAmount(_ parameters: [PaymentsParameterRepresentable]) throws -> Double? {
        
        try paymentsTransferAmount(parameters)
    }
    
    func paymentsTransferMobileConnectionCurrency(_ parameters: [PaymentsParameterRepresentable]) throws -> String {
        
        try paymentsTransferCurrency(parameters)
    }
}
    
// MARK: - Helpers

extension Model {
    
    func getPhoneInfo(
        token: String,
        parameters: [PaymentsParameterRepresentable]
    ) async throws -> ServerCommands.DaDataController.GetPhoneInfo {
        
        let noSevenPhoneNumber = try parameters.value(
            forIdentifier: .mobileConnectionPhone
        )
            .dropFirst(2)
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        let command: ServerCommands.DaDataController.GetPhoneInfo = .init(
            token: token,
            payload: .init(phoneNumbersList: [noSevenPhoneNumber])
        )
        
        return command
    }
    
    func createAnywayTransfer(
        token: String,
        getPhoneInfoPayload: [DaDataPhoneData],
        parameters: [PaymentsParameterRepresentable]
    ) throws -> ServerCommands.TransferController.CreateAnywayTransfer {
        
        let transferPayload = try makeTransferPayload(
            for: getPhoneInfoPayload,
            withParameters: parameters
        ) { [weak self] puref in
            // use local agent to get operators data
            self?.dictionaryAnywayOperator(for: puref)?.operatorID
        }
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(
            token: token,
            isNewPayment: true,
            payload: transferPayload
        )
        
        return command
    }

    func makeTransferPayload(
        for payload: [DaDataPhoneData],
        withParameters parameters: [PaymentsParameterRepresentable],
        operatorID: @escaping (String) -> String?
    ) throws -> ServerCommands.TransferController.CreateAnywayTransfer.Payload {
        
        guard let amountParameter = parameters.parameterAmount
        else {
            
            let parameterID = Payments.Parameter.Identifier.amount
            throw Payments.Error.missingParameter(parameterID.rawValue)
        }
        
        guard let productId = parameters.parameterProduct?.productId,
              let productData = product(productId: productId)
        else {
            
            let parameterID = Payments.Parameter.Identifier.product
            throw Payments.Error.missingParameter(parameterID.rawValue)
        }
        
        let productType = productData.productType
        let payer = try TransferAnywayData.Payer(
            withProductType: productType,
            id: productId
        )
        
        guard let payload = payload.first else {
            
            throw Payments.Error.missingParameter("Payload")
        }
        
        guard let opID = operatorID(payload.puref) else {
            throw Payments.Error.missingParameter("operatorID")
        }
        
        let noSevenPhoneNumber = payload.phone
            .dropFirst(2)
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        let additional = TransferAnywayData.Additional(
            fieldid: 1,
            fieldname: opID,
            fieldvalue: noSevenPhoneNumber
        )
        
        let currency = try paymentsTransferAnywayCurrency(parameters)
        
        return .init(
            amount: amountParameter.amount,
            check: false,
            comment: nil,
            currencyAmount: currency,
            payer: payer,
            additional: [additional],
            puref: payload.puref
        )
    }
    
    func getParameterOperatorLogo(
        parameters: [PaymentsParameterRepresentable]
    ) async throws -> Payments.ParameterOperatorLogo {
        
        let getPhoneInfoPayload = try await getPhoneInfoPayload(
            parameters: parameters
        )
        
        guard let phoneData = getPhoneInfoPayload.first else {
            
            throw Payments.Error.missingParameter("PhoneInfoPayload")
        }
        
        let id = Payments.Parameter.Identifier.mobileConnectionOperatorLogo
        
        return Payments.ParameterOperatorLogo(
            .init(
                id: id.rawValue,
                value: phoneData.puref
            ),
            svgImage: phoneData.svgImage
        )
    }
}

extension OperatorGroupData.OperatorData {
    
    var operatorID: String? { parameter(for: \.id) }
    
    func parameter<Value>(for keyPath: KeyPath<ParameterData, Value>) -> Value? {
        
        parameterList.first.map { $0[keyPath: keyPath] }
    }
}

extension Array where Element == PaymentsParameterRepresentable {

    var parameterAmount: Payments.ParameterAmount? {
        compactMap {
            $0 as? Payments.ParameterAmount
        }.first
    }
    
    var parameterProduct: Payments.ParameterProduct? {
        compactMap {
            $0 as? Payments.ParameterProduct
        }.first
    }
    
    var phoneParameterValue: String {
        get throws {
            try value(forIdentifier: .mobileConnectionPhone)
        }
    }
    
    func parameter(
        forIdentifier identifier: Payments.Parameter.Identifier
    ) throws -> Element {
        
        guard let parameter = first(where: { $0.id == identifier.rawValue })
        else {
            throw Payments.Error.missingParameter(identifier.rawValue)
        }
        
        return parameter
    }
    
    func parameter<T: PaymentsParameterRepresentable>(
        forIdentifier identifier: Payments.Parameter.Identifier,
        as type: T.Type
    ) throws -> T {
        
        let rawValue = identifier.rawValue
        
        guard let parameter = first(where: { $0.id == rawValue })
        else {
            throw Payments.Error.missingParameter(rawValue)
        }
        
        guard let result = parameter as? T
        else {
            throw Payments.Error.unableCreateRepresentable(rawValue)
        }
        
        return result
    }
    
    func value(
        forIdentifier identifier: Payments.Parameter.Identifier
    ) throws -> String {
        
        guard let value = try parameter(forIdentifier: identifier).value
        else {
            throw Payments.Error.missingParameter(identifier.rawValue)
        }
        
        return value
    }
}

private extension TransferData.Payer {
    
    init(
        withProductType productType: ProductType,
        id: ProductData.ID?
    ) throws {
        
        switch productType {
        case .card:
            self.init(
                inn: nil,
                accountId: nil,
                accountNumber: nil,
                cardId: id,
                cardNumber: nil,
                phoneNumber: nil
            )

        case .account:
            self.init(
                inn: nil,
                accountId: id,
                accountNumber: nil,
                cardId: nil,
                cardNumber: nil,
                phoneNumber: nil
            )
            
        default:
            throw Payments.Error.unsupported
        }
    }
}

extension ServerCommands.TransferController.CreateAnywayTransfer.Payload {
    
    var phoneNumber: String? { additional.first?.fieldvalue }
    var operatorID: String? { additional.first?.fieldname }
}

extension ServerCommands.TransferController.CreateAnywayTransfer.Response {
    
    var phoneNumber: String? { data?.additionalList.first?.fieldValue }
}

func json<T: Encodable>(for payload: T) throws -> String {
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(payload)
    
    guard let json = String(data: data, encoding: .utf8)
    else {
        throw NSError(domain: "Error converting data to string", code: 0)
    }
    
    return json
}
