//
//  CardStatementFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation

extension Services {
    
    typealias Payload = CardStatementForPeriodDomain.Payload
    
    static func makeCardStatementForPeriod(
        httpClient: HTTPClient,
        productId: ProductData.ID,
        period: Period,
        name: Payload.Name? = nil,
        statementFormat: StatementFormat? = nil,
        cardNumber: Payload.CardNumber? = nil
    ) async throws-> [ProductStatementData] {
        
        let payload = Payload.init(
            id: .init(productId),
            name: name,
            period: period,
            statementFormat: statementFormat,
            cardNumber: cardNumber)
        let data = try await getCardStatementForPeriod(httpClient: httpClient).process(payload).get()
        return data
    }
    
    private func getCardStatementForPeriod(
        httpClient: HTTPClient
    ) -> Services.GetCardStatementService {
        
        Services.getCardStatementForPeriod(
            httpClient: httpClient
        )
    }
}
