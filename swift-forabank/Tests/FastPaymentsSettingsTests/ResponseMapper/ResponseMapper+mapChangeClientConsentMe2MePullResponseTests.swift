//
//  ResponseMapper+mapChangeClientConsentMe2MePullResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias ChangeClientConsentMe2MePullResult = Result<Int, MappingError>
    
    static func mapChangeClientConsentMe2MePullResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ChangeClientConsentMe2MePullResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapChangeClientConsentMe2MePullResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.ChangeClientConsentMe2MePullResult {
        
        ResponseMapper.mapChangeClientConsentMe2MePullResponse(data, httpURLResponse)
    }
}
