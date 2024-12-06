//
//  C2BSubscribeFactory.swift
//  Vortex
//
//  Created by Andryusina Nataly on 26.09.2023.
//

import Foundation

extension Model {
    
    func paymentsStepC2BSubscribe(
        by qrLink: QRLink
    ) async throws -> QRScenarioData {
        return try await getC2BSubscribe().process(qrLink).get()
    }
    
    private func getC2BSubscribe() -> Services.GetScenarioQRData {
        
        Services.getScenarioQRData(
            httpClient: cachelessAuthorizedHTTPClient()
        )
    }
}
