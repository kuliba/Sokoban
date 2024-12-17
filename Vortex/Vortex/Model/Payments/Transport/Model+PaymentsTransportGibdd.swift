//
//  Model+PaymentsTransportGibdd.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.06.2023.
//

extension Model {
    
    // MARK: - Process Local Step
    
    func paymentsProcessLocalStepGibdd(
        parameters: [PaymentsParameterRepresentable],
        for stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            
            if try await isSingleService(Purefs.iForaGibdd) {
                
                throw Payments.Error.unexpectedIsSingleService
            }
            
            // operator
            let operatorParameter = Payments.ParameterOperator(operatorType: .gibdd)
            
            // header
            let headerParameter = transportHeader(
                forPuref: Purefs.iForaGibdd,
                title: "Штрафы ГИБДД"
            )
            
            // product
            let productParameter = try transportProduct()
            
            // selector
            let selectParameter = Payments.ParameterSelectDropDownList.gibdd
            
            return .init(
                parameters: [
                    operatorParameter,
                    headerParameter,
                    productParameter,
                    selectParameter
                ],
                front: .init(
                    visible: [
                        headerParameter.id,
                        selectParameter.id
                    ],
                    isCompleted: true
                ),
                back: .init(
                    stage: .remote(.start),
                    required: [selectParameter.id],
                    processed: nil
                )
            )
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    // MARK: Process Remote Step Next
    
    func paymentsProcessRemoteNextGibdd(
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
            .category,
        ]
        let excluding2 = [
            "a3_DriverLicence_1_1",
            "a3_RegCert_2_1",
            "warning",
            "a3_iDriverLicence_1_4",
            "a3_iBillNumber_2_4",
            "a3_iBillDate_3_4",
            "a3_iUIN_4_4",
            "a3_iRecipientName_5_4",
            "a3_iRecipientINN_6_4",
            "a3_iRecipientKPP_7_4",
            "a3_iRecipientAccount_8_4",
            "a3_iRecipientBankName_9_4",
            "a3_iRecipientBIC_10_4",
            "a3_iRecipientOKATO_11_4",
            "a3_iRecipientKBK_12_4",
            "a3_amount_13_4",
        ]
        let additional = paymentsTransferGibddAdditional(
            parameters.map(\.parameter),
            excluding: excludingParameters.map(\.rawValue) + excluding2
        )
        
        let command = ServerCommands.TransferController.CreateAnywayTransfer(token: token, isNewPayment: isNewPayment, payload: .init(amount: amount, check: false, comment: comment, currencyAmount: currency, payer: payer, additional: additional, puref: puref))
        
        return try await serverAgent.executeCommand(command: command)
    }
    
    func paymentsTransferGibddAdditional(
        _ parameters: [Payments.Parameter],
        excluding excludingParameterIDs: [String]
    ) -> [TransferAnywayData.Additional] {
        
        return parameters
            .filter { !excludingParameterIDs.contains($0.id) }
            .enumerated()
            .compactMap { (index, parameter) -> TransferAnywayData.Additional? in
                
                guard let parameterValue = parameter.value,
                      !parameterValue.isEmpty
                else { return nil }
                
                return .init(
                    fieldid: index + 1,
                    fieldname: parameter.id,
                    fieldvalue: parameterValue
                )
            }
    }
    
    // MARK: Process Remote Step
    
    func paymentsProcessRemoteGibdd(
        _ operation: Payments.Operation,
        response: TransferAnywayResponseData
    ) async throws -> Payments.Operation.Step {
        
        let nextParameters = try await uniqueNextParameters(
            for: operation,
            with: response
        )
        
        let restrictedParameters = ["a3_DriverLicence_1_2", "a3_RegCert_2_2"]
        
        let next = nextParameters.map {
            
            guard let parameter = $0 as? Payments.ParameterInput,
                  restrictedParameters.contains(parameter.parameter.id)
            else { return $0 }
            
            let rules = parameter.validator.rules.relaxed
            
            return parameter.replacingValidator(with: .init(rules: rules))
        }
        
        let step = try step(
            for: operation,
            withNextParameters: next,
            restrictedParameters: restrictedParameters,
            response: response
        )
        
        // DBSNEW-9403: use semi-duplicated input fields for GIBDD to show no fines alert
        let parametersToExclude = ["a3_DriverLicence_1_1", "a3_RegCert_2_1"]
        let badIDs = step.parameters.map(\.id).filter {
            parametersToExclude.contains($0)
        }
        let penaltyList = response.parameterListForNextStep.filter { $0.id == "a3_PenaltyList_1_2" }
        let warning = step.parameters.first { $0.id == "warning" }
        
        guard !badIDs.isEmpty,
              penaltyList.isEmpty,
              let message = warning?.value
        else { return step }
        
        throw Payments.Error.action(.alert(title: "", message: message))
    }
}

// MARK: - Helpers

private extension Payments.ParameterSelectDropDownList {
    
    static let gibdd: Self = .init(
        .init(
            id: "a3_SearchType_1_1",
            value: "20"
        ),
        title: "Тип документа",
        options: [
            .init(id: "20", name: "ВУ или СТС", icon: .name("ic24FileHash")),
            .init(id: "30", name: "Номер УИН", icon: .name("ic24Hash")),
        ],
        placement: .top
    )
}


private extension Array where Element == PaymentsValidationRulesSystemRule {
    
    var relaxed: Self {
        
        map {
            
            guard let rule = $0 as? Payments.Validation.RegExpRule
            else { return $0 }
            
            return rule.relaxed
        }
    }
}

extension Payments.Validation.RegExpRule {
    
    var relaxed: Payments.Validation.OptionalRegExpRule {
        
        return .init(regExp: regExp, actions: actions)
    }
}

private extension Payments.ParameterInput {
    
    func replacingValidator(
        with validator: Payments.Validation.RulesSystem
    ) -> Self {
        
        .init(
            parameter,
            icon: icon,
            title: title,
            hint: hint,
            info: info,
            validator: validator,
            limitator: limitator,
            isEditable: isEditable,
            placement: placement,
            inputType: inputType,
            group: group
        )
    }
}
