//
//  C2BFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.09.2023.
//

import Foundation

extension Model {
    
    func paymentsStepC2B(
        by qrLink: QRLink
    ) async throws -> (
        parameters: [PaymentsParameterRepresentable],
        visible: [Payments.Operation.Step.Parameter.ID]
    ) {
        let data = try await getC2B().process(qrLink).get()
        return try c2BParameters(
            data: data,
            parameters: [],
            visible: []
        )
    }
    
    private func getC2B(
    ) -> Services.GetScenarioQRData {
        
        Services.getScenarioQRData(
            httpClient: cachelessAuthorizedHTTPClient()
        )
    }
}
