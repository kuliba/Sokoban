//
//  RequestFactory+createGetPrintFormRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2023.
//

import Foundation
import Tagged

extension RequestFactory {
    
    static func createGetPrintFormRequest(
        printFormType: PrintFormType
    ) -> (DocumentID) throws -> URLRequest {
        
        return { documentID in
            
            let endpoint = Services.Endpoint.getPrintForm
            let url = try! endpoint.url(
                withBase: Config.serverAgentEnvironment.baseURL
            )
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try JSONSerialization.data(withJSONObject: [
                "paymentOperationDetailId": "\(documentID.rawValue)",
                "printFormType": "\(printFormType.rawValue)"
            ] as [String: String])
            
            return request
        }
    }
    
    enum PrintFormType: String {
        
        case sticker = "sticker"
        case service = "housingAndCommunalService"
    }
}
