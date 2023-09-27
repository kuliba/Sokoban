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
    typealias GetScenarioQRData = RemoteService<GetScenarioQR, QRScenarioData?>
    
    static func getScenarioQRData(
        httpClient: HTTPClient
    ) -> GetScenarioQRData {
        
        return .init(
            createRequest: RequestFactory.getScenarioQRDataRequest,
            performRequest: httpClient.performRequest,
            mapResponse: { try QrDataMapper.map($0, $1).get() }
        )
    }
}
