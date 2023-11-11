//
//  Services+getScenarioQRData.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 26.09.2023.
//

import Foundation
import GenericRemoteService

extension Services {
    
    typealias GetScenarioQR = (QRLink)
    typealias GetScenarioResult = Swift.Result<QRScenarioData, QrDataMapper.MapperError>
    typealias GetScenarioQRData = RemoteService<GetScenarioQR, GetScenarioResult, Error, Error, Error>
    
    static func getScenarioQRData(
        httpClient: HTTPClient
    ) -> GetScenarioQRData {
        
        return .init(
            createRequest: RequestFactory.getScenarioQRDataRequest,
            performRequest: httpClient.performRequest,
            mapResponse: { QrDataMapper.map($0, $1) }
        )
    }
}
