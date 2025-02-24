//
//  RequestFactory+createGetBannersMyProductListRequest.swift
//  
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import Foundation
import RemoteServices
import VortexTools

public extension RequestFactory {

    static func createGetBannersMyProductListRequest(
        serial: String? = nil,
        url: URL
    ) throws -> URLRequest {
        
//        let url = try url.appendingSerial(serial)
        return createEmptyRequest(.get, with: url)
    }
}
