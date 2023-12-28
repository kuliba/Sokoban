//
//  ResponseMapper+mapGetClientConsentMe2MePullResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias GetClientConsentMe2MePullResult = Result<Int, MappingError>
    
    static func mapGetClientConsentMe2MePullResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetClientConsentMe2MePullResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapGetClientConsentMe2MePullResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.GetClientConsentMe2MePullResult {
        
        ResponseMapper.mapGetClientConsentMe2MePullResponse(data, httpURLResponse)
    }
}
