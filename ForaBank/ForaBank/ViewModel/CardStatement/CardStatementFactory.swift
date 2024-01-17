//
//  CardStatementFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation

extension Model {
    
    func getCardStatementForPeriod(
        productId: ProductData.ID,
        period: Period,
        name: CardStatementForPeriodDomain.Payload.Name? = nil,
        statementFormat: StatementFormat? = nil,
        cardNumber: CardStatementForPeriodDomain.Payload.CardNumber? = nil
    ) async throws-> [ProductStatementData] {
        
        let data = try await getCardStatementForPeriod().process(.init(
            id: .init(productId),
            name: name,
            period: period,
            statementFormat: statementFormat,
            cardNumber: cardNumber)).get()
        return data
    }
    
    private func getCardStatementForPeriod(
    ) -> Services.GetCardStatementData {
        
        Services.getCardStatementForPeriod(
            httpClient: authenticatedHTTPClient()
        )
    }
}
