//
//  RequestFactory+createGetPrintFormRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2023.
//

import Foundation
import Tagged

typealias DetailID = Tagged<_DetailID, Int>
enum _DetailID {}

extension RequestFactory {
    
    static func createGetPrintFormRequest(
        detailID: DetailID
    ) throws -> URLRequest {
        
        let endpoint = Services.Endpoint.getPrintForm
        let url = try! endpoint.url(
            withBase: Config.serverAgentEnvironment.baseURL
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "paymentOperationDetailId": "\(detailID.rawValue)",
            "printFormType": "sticker"
        ] as [String: String])
        
        return request
    }
}
