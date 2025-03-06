//
//  ResponseMapper+mapGetSplashScreenImageResponse.swift
//
//
//  Created by Nikolay Pochekuev on 04.03.2025.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetSplashScreenImageResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<Data> {
        
        map(data, httpURLResponse)
    }
}
