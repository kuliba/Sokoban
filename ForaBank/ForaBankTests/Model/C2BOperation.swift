//
//  C2BOperation.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 18.08.2023.
//

@testable import ForaBank
import XCTest

extension XCTestCase {
    
    func c2bOperationWithParameter(
        // TODO: change default value to nil and fix tests setup
        amountValue: String? = "10",
        amountComplete: Bool = true,
        parameters: [PaymentsParameterRepresentable] = []
    ) -> Payments.Operation {
        
        let parameters = parameters + [
            Payments.ParameterMock(id: Payments.Parameter.Identifier.product.rawValue, value: "1"),
            Payments.ParameterMock(id: Payments.Parameter.Identifier.c2bIsAmountComplete.rawValue, value: amountComplete.description),
            Payments.ParameterAmount(
                value: amountValue,
                title: "",
                currencySymbol: "",
                validator: .init(minAmount: 0, maxAmount: 10)
            )
        ]
        
        return .init(
            service: .c2b,
            source: .c2b(anyURL()),
            steps: [
                .init(
                    parameters: parameters,
                    front: .init(
                        visible: [],
                        isCompleted: true
                    ),
                    back: .init(
                        stage: .remote(.complete),
                        required: [],
                        processed: [])
                )
            ],
            visible: [])
    }
}
