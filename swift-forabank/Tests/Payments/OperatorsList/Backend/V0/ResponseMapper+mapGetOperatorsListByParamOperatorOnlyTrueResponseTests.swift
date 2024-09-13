//
//  ResponseMapper+mapGetOperatorsListByParamOperatorOnlyTrueResponseTests.swift
//  
//
//  Created by Igor Malyarov on 13.09.2024.
//

import OperatorsListBackendV0
import XCTest

final class ResponseMapper_mapGetOperatorsListByParamOperatorOnlyTrueResponseTests: XCTestCase {
    
    func test() throws {
        
        let _ = try data(from: "getOperatorsListByParam_prod")
    }
    
    private func data(
        from filename: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Data {
        
        let filename = Bundle.module.url(forResource: filename, withExtension: "json")
        let url = try XCTUnwrap(filename, file: file, line: line)
        return try Data(contentsOf: url)
    }
}
