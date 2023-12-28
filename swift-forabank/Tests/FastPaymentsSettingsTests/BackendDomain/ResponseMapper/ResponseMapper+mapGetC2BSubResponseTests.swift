//
//  ResponseMapper+mapGetC2BSubResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias GetC2BSubResult = Result<Int, MappingError>
    
    static func mapGetC2BSubResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> GetC2BSubResult {
        
        .failure(.invalid(statusCode: -1, data: .init()))
    }
}

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapGetC2BSubResponseTests: XCTestCase {
    
    func test() {
        
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> ResponseMapper.GetC2BSubResult {
        
        ResponseMapper.mapGetC2BSubResponse(data, httpURLResponse)
    }
}
