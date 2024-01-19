//
//  RequestFactory+getCardStatementForPeriod.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 16.01.2024.
//

import Foundation
import Tagged

extension RequestFactory {
    
    static func getCardStatementForPeriod(
        payload: CardStatementForPeriodDomain.Payload
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getCardStatementForPeriod
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try payload.json
        return request
    }
}

private extension CardStatementForPeriodDomain.Payload {
    
    var json: Data {
      
        get throws {
            
            let formatter = DateFormatterISO8601()
            
            let startDateFormattedString = formatter.string(from: period.start)
            let endDateFormattedString = formatter.string(from: period.end)
            
            var parameters: [String: Any] = [
                "id": id.rawValue,
                "startDate": startDateFormattedString,
                "endDate": endDateFormattedString
            ]
            
            let name: [String: String]? = name.map { ["name": $0.rawValue] }
            if let name { parameters = parameters.mergeOnto(target: name) }
            
            let statementFormat: [String: String]? = statementFormat.map { ["statementFormat": $0.rawValue] }
            if let statementFormat { parameters = parameters.mergeOnto(target: statementFormat) }
            
            let cardNumber: [String: String]? = cardNumber.map { ["cardNumber": $0.rawValue] }
            if let cardNumber { parameters = parameters.mergeOnto(target: cardNumber) }
            
            return try JSONSerialization.data(withJSONObject: parameters
                                              as [String: Any])
        }
    }
}

private extension Dictionary where Value: Any {
    func mergeOnto(target: [Key: Value]?) -> [Key: Value] {
        guard let target = target else { return self }
        return self.merging(target) { current, _ in current }
    }
}
