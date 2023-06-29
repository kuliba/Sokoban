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
        
        return try step(
            for: operation,
            withNextParameters: next,
            restrictedParameters: restrictedParameters,
            response: response
        )
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
