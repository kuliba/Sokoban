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
    
    // MARK: - Process Remote Step
    
    func paymentsProcessRemoteStepGibdd(
        _ operation: Payments.Operation,
        response: TransferAnywayResponseData
    ) async throws -> Payments.Operation.Step {
        
        let step = try await step(for: operation, with: response)
        let amount = try makeAvtodorAmount(with: step.parameters)
        
        return Payments.Operation.Step(
            parameters: step.parameters + [amount],
            front: step.front,
            back: step.back
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
