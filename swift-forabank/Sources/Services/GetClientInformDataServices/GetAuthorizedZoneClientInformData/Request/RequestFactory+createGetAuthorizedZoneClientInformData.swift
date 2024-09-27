//
//  File.swift
//  
//
//  Created by Nikolay Pochekuev on 26.09.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetAuthorizedZoneClientInformData(
        url: URL
    ) throws -> URLRequest {
        
        createEmptyRequest(.get, with: url)
    }
}
