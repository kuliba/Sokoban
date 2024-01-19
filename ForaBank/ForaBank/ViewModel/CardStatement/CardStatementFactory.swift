//
//  CardStatementFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation
import CardStatementAPI
import Tagged

extension Services {
    
    typealias CardStatementForPeriodPayload = CardStatementForPeriodDomain.Payload
    
    static func makeCardStatementForPeriod(
        httpClient: HTTPClient,
        productId: ProductData.ID,
        period: Period,
        name: CardStatementForPeriodPayload.Name? = nil,
        statementFormat: StatementFormat? = nil,
        cardNumber: CardStatementForPeriodPayload.CardNumber? = nil
    ) async throws-> [ProductStatementData] {
        
        let payload = CardStatementForPeriodPayload.init(
            id: .init(productId),
            name: name,
            period: period,
            statementFormat: statementFormat,
            cardNumber: cardNumber)
        let data = try await getCardStatementForPeriod(httpClient: httpClient).process(payload).get()
        
        return data.map { .init(data: $0) }
    }
    
    private func getCardStatementForPeriod(
        httpClient: HTTPClient
    ) -> Services.GetCardStatementService {
        
        Services.getCardStatementForPeriod(
            httpClient: httpClient
        )
    }
}

// TODO: доделать!!!
extension ProductStatementData {
    
    init(
        data: CardStatementAPI.ProductStatementData
    ) {
        fatalError("unimplemented")
    }
}
