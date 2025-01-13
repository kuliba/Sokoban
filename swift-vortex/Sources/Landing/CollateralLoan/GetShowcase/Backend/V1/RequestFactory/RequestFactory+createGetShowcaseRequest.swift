//
//  RequestFactory+createGetShowcaseRequest.swift
//  Vortex
//
//  Created by Valentin Ozerov on 04.10.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {

    static func createGetShowcaseRequest(url: URL) -> URLRequest {
        
        return createEmptyRequest(.get, with: url)
    }
}
