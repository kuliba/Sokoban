//
//  Model+PaymentsServices.swift
//  ForaBank
//
//  Created by Andryushina Nataly on 22.03.2023.
//

import Foundation

// MARK: - Step
extension Model {
    
    func paymentsProcessLocalStepServices(
        _ operation: Payments.Operation,
        for stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        switch stepIndex {
        case 0:
            
            switch operation.source {
            case .latestPayment:

                let dataByOperation = try dataByOperation(operation)
                
                let operatorCode = dataByOperation.puref
                let amount = dataByOperation.amount
                let isSingle = try await isSingleService(operatorCode)
                return try await paymentsProcessLocalStepServicesStep0(
                    operatorCode: operatorCode,
                    additionalList: dataByOperation.additionalList,
                    amount: amount,
                    isSingle: isSingle)
                
            case .servicePayment(let operatorCode,
                                 let additionalList,
                                 let amount):
                
                let isSingle = try await isSingleService(operatorCode)
                return try await paymentsProcessLocalStepServicesStep0(
                    operatorCode: operatorCode,
                    additionalList: additionalList,
                    amount: amount,
                    isSingle: isSingle)
                
            default:
                throw Payments.Error.missingSource(operation.service)
            }
            
        default:
            
            throw Payments.Error.unsupported
        }
    }
    
    func paymentsProcessLocalStepServicesStep0(
        operatorCode: String,
        additionalList: [PaymentServiceData.AdditionalListData]?,
        amount: Double,
        isSingle : Bool
    ) async throws -> Payments.Operation.Step {
        
        guard let operatorValue = self.dictionaryAnywayOperator(for: operatorCode) else {
            throw Payments.Error.missingValueForParameter(operatorCode)
        }
        
        let productParameterId = Payments.Parameter.Identifier.product.rawValue
        let filter = ProductData.Filter.generalFrom
        
        guard let product = firstProduct(with: filter) else {
            throw Payments.Error.unableCreateRepresentable(productParameterId)
        }
        
        var parameters: [PaymentsParameterRepresentable] = []
        var visible: [String] = []
        var required: [String] = []
        
        let operatorParameter = Payments.ParameterOperator(
            operatorType: operatorCode
        )
        parameters.append(operatorParameter)
        
        let headerParameter = Payments.ParameterHeader(
            title: "\(operatorValue.name)",
            subtitle: operatorValue.description,
            icon: .image(operatorValue.logotypeList.first?.iconData ?? .empty)
        )
        parameters.append(headerParameter)
        visible.append(headerParameter.id)
        
        let productParameter = Payments.ParameterProduct(value: String(product.id), filter: filter, isEditable: true)
        parameters.append(productParameter)
        required.append(productParameter.id)
        let parametersList = operatorValue.parameterList.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        for parameterData in parametersList {
            
            if let parameterValue = paymentsParameterRepresentableServices(additionalList: additionalList, parameterData: parameterData) {
                
                parameters.append(parameterValue)
            }
            
            if let visibleParameterId = paymentsParameterVisible(parameterData: parameterData) {
                
                visible.append(visibleParameterId)
            }
            
            if let requiredParameterId = paymentsParameterRequired(parameterData: parameterData) {
                
                required.append(requiredParameterId)
            }
        }
        
        if isSingle {
            
            guard let currencySymbol = dictionaryCurrencySymbol(for: product.currency) else {
                throw Payments.Error.unableCreateRepresentable(productParameterId)
            }
            
            visible.append(productParameter.id)
            
            let amountParameter = Payments.ParameterAmount(
                value: "\(amount)",
                title: "Сумма платежа",
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
            parameters.append(amountParameter)
            visible.append(amountParameter.id)
            required.append(amountParameter.id)
        }
        
        return .init(
            parameters: parameters,
            front: .init(
                visible: visible,
                isCompleted: false
            ),
            back: .init(
                stage: .remote(.start),
                required: required,
                processed: nil)
        )
    }
    
    func paymentsParameterRepresentableServices(
        additionalList: [PaymentServiceData.AdditionalListData]?,
        parameterData: ParameterData
    ) -> PaymentsParameterRepresentable? {
        
        if parameterData.viewType == .input {
            
            let operatorParameterId = parameterData.id
            switch parameterData.view {
                
            case .input:
                
                let regExp: PaymentsValidationRulesSystemRule = parameterData.isRequired == true ? Payments.Validation.RegExpRule(regExp:parameterData.regExp ?? "", actions: [.post: .warning((parameterData.subTitle ?? ""))]) : Payments.Validation.OptionalRegExpRule(regExp:parameterData.regExp ?? "", actions: [.post: .warning((parameterData.subTitle ?? ""))])
                var value: String?
                if let additionalList = additionalList {
                    
                    let additionalValue = additionalList.filter({$0.fieldName == operatorParameterId}).first
                    value = additionalValue?.fieldValue ?? nil
                }
                return (Payments.ParameterInput(
                    .init(id: operatorParameterId, value: value),
                    icon: (ImageData(with: parameterData.svgImage ?? .init(description: ""))),
                    title: parameterData.title,
                    validator: .init(rules: [regExp]),
                    inputType: .default))
                
            case .select:
                
                if let options = parameterData.options(style: .general) {
                    
                    var value: String?
                    if let additionalList = additionalList {
                        let additionalValue = additionalList.filter({$0.fieldName == operatorParameterId}).first
                        value = additionalValue?.fieldValue ?? nil
                    }
                    return (Payments.ParameterSelect(
                        Payments.Parameter(id: operatorParameterId, value: value),
                        icon: .image(parameterData.iconData ?? .iconInput),
                        title: parameterData.title,
                        placeholder: "Начните ввод для поиска",
                        options: options.map({ .init(id: $0.id, name: $0.name)})))
                } else if let options = parameterData.options(style: .extended) {
                    
                    var value: String?
                    if let additionalList = additionalList {
                        let additionalValue = additionalList.filter({$0.fieldName == operatorParameterId}).first
                        value = additionalValue?.fieldValue ?? nil
                    }
                    return (Payments.ParameterSelect(
                        Payments.Parameter(id: operatorParameterId, value: value),
                        icon: .image(parameterData.iconData ?? .iconInput),
                        title: parameterData.title,
                        placeholder: "Начните ввод для поиска",
                        options: options.map({ .init(id: $0.id, name: $0.name)})))
                }
                
            default:
                return nil
            }
        }
        return nil
    }
    
    func paymentsParameterVisible(
        parameterData: ParameterData
    ) -> String? {
        if parameterData.viewType == .input  {
            
            let operatorParameterId = parameterData.id
            switch parameterData.view {
                
            case .input:
                return operatorParameterId
                
            case .select:
                
                if (parameterData.options(style: .general) != nil) || (parameterData.options(style: .extended) != nil) {
                    
                    return operatorParameterId
                }
                
            default:
                return nil
            }
        }
        return nil
    }
    
    func paymentsParameterRequired(
        parameterData: ParameterData
    ) -> String? {
        
        if parameterData.viewType == .input {
            let operatorParameterId = parameterData.id
            switch parameterData.view {
                
            case .input:
                if parameterData.isRequired == true {
                    
                    return operatorParameterId
                }
                
            case .select:
                if (parameterData.options(style: .general) != nil) {
                    
                    if parameterData.isRequired == true {
                        
                        return operatorParameterId
                    }
                }
            default:
                return nil
            }
        }
        return nil
    }
    
    func paymentsProcessRemoteStepServices(operation: Payments.Operation,
                                           response: TransferResponseData)
    async throws -> Payments.Operation.Step {
        
        var parameters = [PaymentsParameterRepresentable]()
        let group = Payments.Parameter.Group(id: UUID().uuidString, type: .info)
        
        if let amountCurrency = response.debitAmount,
           let amountFormatted = paymentsAmountFormatted(amount: amountCurrency, parameters: operation.parameters){
            
            let amountParameterId = Payments.Parameter.Identifier.paymentsServiceAmount.rawValue
            let amountParameter = Payments.ParameterInfo(
                .init(id: amountParameterId, value: amountFormatted),
                icon: ImageData(named: "ic24Coins") ?? .parameterDocument,
                title: "Сумма списания",
                placement: .feed,
                group: group)
            
            parameters.append(amountParameter)
        }
        
        if let feeAmount = response.fee,
           let feeAmountFormatted = paymentsAmountFormatted(amount: feeAmount, parameters: operation.parameters) {
            
            let feeParameterId = Payments.Parameter.Identifier.fee.rawValue
            let feeParameter = Payments.ParameterInfo(
                .init(id: feeParameterId, value: feeAmountFormatted),
                icon: .init(named: "ic24PercentCommission") ?? .parameterDocument,
                title: "Комиссия",
                placement: .feed,
                group: group)
            
            parameters.append(feeParameter)
        }
        
        if response.needOTP == true {
            
            let parameterOperatorLogo = try await getParameterOperatorLogoForServices(
                operation: operation
            )
            parameters.append(parameterOperatorLogo)
            parameters.append(Payments.ParameterCode.regular)
            return .init(parameters: parameters, front: .init(visible: parameters.map(\.id), isCompleted: false), back: .init(stage: .remote(.confirm), required: [], processed: nil))
        }
        else {
            
            return .init(parameters: parameters, front: .init(visible: parameters.map(\.id), isCompleted: false), back: .init(stage: .remote(.next), required: [], processed: nil))
        }
    }
    
    func paymentsServicesStepVisible(_ operation: Payments.Operation, nextStepParameters: [PaymentsParameterRepresentable], operationParameters: [PaymentsParameterRepresentable], response: TransferAnywayResponseData) throws -> [Payments.Parameter.ID] {
        
        var result = [Payments.Parameter.ID]()
        
        let nexStepParametersIds = nextStepParameters.map(\.id)
        result.append(contentsOf: nexStepParametersIds)
        
        if response.needSum {
            
            let operationParametersIds = operationParameters.map(\.id)
            let allParametersIds = operationParametersIds + nexStepParametersIds
            
            let productParameterId = Payments.Parameter.Identifier.product.rawValue
            guard allParametersIds.contains(productParameterId) else {
                throw Payments.Error.missingParameter(productParameterId)
            }
            
            result.append(Payments.Parameter.Identifier.product.rawValue)
        }
        return result
    }
    
    func paymentsServicesStepExcludingParameters(response: TransferAnywayResponseData)
    throws -> [Payments.Parameter.ID] {
        
        var result = [Payments.Parameter.ID]()
        // isRequired is optional value - need '== false'
        let nexStepParametersIds = response.parameterListForNextStep.filter({ $0.isRequired == false }).map(\.id)
        result.append(contentsOf: nexStepParametersIds)
        return result
    }
    
    func paymentsServicesStepStage(_ operation: Payments.Operation,
                                   response: TransferAnywayResponseData)
    throws -> Payments.Operation.Stage {
        
        if response.finalStep {
            
            return .remote(.confirm) } else {
                
                let operationStepsStages = operation.steps.map(\.back.stage)
                if !operationStepsStages.isEmpty {
                    
                    return .remote(.next)
                } else {
                    
                    return .remote(.start)
                }
            }
    }
    
    func paymentsServicesStepRequired(_ operation: Payments.Operation,
                                      visible: [Payments.Parameter.ID],
                                      nextStepParameters: [PaymentsParameterRepresentable],
                                      operationParameters: [PaymentsParameterRepresentable],
                                      excludingParameters: [Payments.Parameter.ID])
    throws -> [Payments.Parameter.ID] {
        
        try paymentsTransferStepRequired(
            operation,
            visible: visible,
            nextStepParameters: nextStepParameters,
            operationParameters: operationParameters,
            restrictedParameters: excludingParameters
        )
    }
    
    func getParameterOperatorLogoForServices(
        operation: Payments.Operation
    ) async throws -> Payments.ParameterOperatorLogo {
        var operatorCode = ""
        switch operation.source {
        case .latestPayment:
            
            let dataByOperation = try dataByOperation(operation)
            operatorCode = dataByOperation.puref

        case .servicePayment(let code, _, _):
            
            operatorCode = code
            
        default:
            throw Payments.Error.missingSource(operation.service)
        }
        
        guard let operatorValue = self.dictionaryAnywayOperator(for: operatorCode) else {
            throw Payments.Error.missingValueForParameter(operatorCode)
        }
        
        let puref = operatorValue.code
        let svgImage: String = operatorValue.logotypeList.first?.svgImage?.description ?? ""
        
        let id = Payments.Parameter.Identifier.paymentsServiceOperatorLogo
        
        return Payments.ParameterOperatorLogo(
            .init(
                id: id.rawValue,
                value: puref
            ),
            svgImage: svgImage
        )
    }
    
    
    func paymentsProcessRemoteServicesComplete(
        code: String,
        operation: Payments.Operation
    ) async throws -> Payments.Success {
        
        let response = try await paymentsTransferComplete(
            code: code
        )
        let operatorLogo = try operation.parameters.parameter(
            forIdentifier: .paymentsServiceOperatorLogo,
            as: Payments.ParameterOperatorLogo.self
        )
        let data = PaymentsServicesData(
            svgImageData: .init(description: operatorLogo.svgImage)
        )
        let success = try Payments.Success(
            with: response,
            operation: operation,
            serviceData: .paymentsServicesData(data)
        )
        
        return success
    }
}

//MARK: - resets visible items and order

extension Model {
    
    func paymentsProcessOperationResetVisibleToPaymentsServices(_ operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
        
        // check if current step stage is confirm
        guard case .remote(let remote) = operation.steps.last?.back.stage,
              remote == .confirm else {
            return nil
        }
        
        return operation.visible.filter({$0 != Payments.Parameter.Identifier.amount.rawValue})
    }
    
}

//MARK: - helpers
extension Model {
    
    func accountNumberForPayment(qrCode: QRCode) -> String {
        
        if let account = qrCode.rawData["persacc"] {
            
            return account
        }
        if let phone = qrCode.rawData["phone"] {
            
            return phone
        }
        if let numAbo = qrCode.rawData["numabo"] {
            
            return numAbo
        }
        return ""
    }
    
    func additionalList(for operatorData: OperatorGroupData.OperatorData, qrCode: QRCode) -> [PaymentServiceData.AdditionalListData]? {
        
        operatorData.parameterList.compactMap {
            
            if $0.viewType == .input {
                
                let value: String = ($0.inputFieldType == .account ? accountNumberForPayment(qrCode: qrCode) : "")
                return PaymentServiceData.AdditionalListData(
                    fieldTitle: $0.title,
                    fieldName: $0.id,
                    fieldValue: value,
                    svgImage: $0.svgImage?.description
                )
            } else {
                
                return nil
            }
        }
    }
    
    func dataByOperation (_ operation: Payments.Operation) throws -> (puref: String, amount: Double, additionalList: [PaymentServiceData.AdditionalListData]) {
        switch operation.source {
        case let .latestPayment(latestPaymentId):
            
            guard let latestPayment = self.latestPayments.value.first(where: { $0.id == latestPaymentId }),
                  let latestPayment = latestPayment as? PaymentServiceData else {
                throw Payments.Error.missingSource(operation.service)
            }
            
            let operatorCode = latestPayment.puref
            let amount = latestPayment.amount
            let additionalListData = latestPayment.additionalList
            return (puref: operatorCode, amount: amount, additionalList: additionalListData)
            
        default:
            throw Payments.Error.missingSource(operation.service)
        }
    }
}

extension Model {
    
    func paymentsParameterRepresentablePaymentsServices(
        parameterData: ParameterData
    ) async throws -> PaymentsParameterRepresentable? {
        
        switch parameterData.view {
        case .select:
            guard let options = parameterData.options(style: .general) else {
                return nil
            }
            
            let selectOptions = options
                .compactMap{ $0 }
                .map(Payments.ParameterSelect.Option.init)
            
            return Payments.ParameterSelect(.init(id: parameterData.id,
                                                  value: parameterData.value),
                                            title: parameterData.title,
                                            placeholder: "Начните ввод для поиска",
                                            options: selectOptions)
            
        case .input:
            switch parameterData.id {
            default:
                let regExp: PaymentsValidationRulesSystemRule = parameterData.isRequired == true ? Payments.Validation.RegExpRule(regExp:parameterData.regExp ?? "", actions: [.post: .warning((parameterData.subTitle ?? ""))]) : Payments.Validation.OptionalRegExpRule(regExp:parameterData.regExp ?? "", actions: [.post: .warning((parameterData.subTitle ?? ""))])
                
                return Payments.ParameterInput(
                    .init(id: parameterData.id, value: parameterData.value),
                    icon: parameterData.iconData ?? .parameterDocument,
                    title: parameterData.title,
                    validator: .init(rules: [regExp]))
            }
            
        case .info:
            return Payments.ParameterInfo(
                .init(id: parameterData.id, value: parameterData.value),
                icon: parameterData.iconData ?? .parameterDocument,
                title: parameterData.title,
                group: .init(id: "info", type: .info))
            
        case .selectSwitch:
            return nil
        }
    }
}
