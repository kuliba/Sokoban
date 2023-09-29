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
        
        guard let data = try await getC2B().process(qrLink)
        else {
            throw Payments.Error.action(.alert(title: "Ошибка", message: "Не смогли получить данные"))
        }
        
        return try c2BParameters(
            data: data,
            parameters: [],
            visible: []
        )
    }
    
    private func getC2B(
    ) -> Services.GetScenarioQRData {
        
        Services.getScenarioQRData(
            httpClient: authorizedHTTPClient()
        )
    }
}
