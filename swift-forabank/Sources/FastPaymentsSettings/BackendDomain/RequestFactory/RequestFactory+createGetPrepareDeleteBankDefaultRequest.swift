//
//  RequestFactory+createGetPrepareDeleteBankDefaultRequest.swift
//
//
//  Created by Дмитрий Савушкин on 29.09.2024.
//

    import Foundation
    import RemoteServices

    public extension RequestFactory {
        
        static func createPrepareDeleteBankDefaultRequest(
            url: URL
        ) -> URLRequest {
            
            createEmptyRequest(.get, with: url)
        }
    }
