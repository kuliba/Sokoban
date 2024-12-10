//
//  RequestFactory+createGetOperatorsListByParamOperatorOnlyFalseRequestTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 16.05.2024.
//

@testable import ForaBank
import XCTest

final class RequestFactory_createGetOperatorsListByParamOperatorOnlyFalseRequestTests: XCTestCase {
    
    func test_createRequest_shouldThrowOnEmptyOperatorID() throws {
        
        try XCTAssertThrowsError(createRequest(
            makeUtilityPaymentOperator(id: "")
        ))
    }
    
    func test_createRequest_shouldSetRequestURL() throws {
        
        let operatorID = UUID().uuidString
        let type = UUID().uuidString
        let request = try createRequest(makeUtilityPaymentOperator(
            id: operatorID,
            type: type
        ))
        
        XCTAssertNoDiff(
            request.url?.absoluteString,
            "https://pl.forabank.ru/dbo/api/v3/dict/getOperatorsListByParam?customerId=\(operatorID)&operatorOnly=false&type=\(type)"
        )
    }
    
    func test_createRequest_shouldSetRequestMethodToGet() throws {
        
        let request = try createRequest()
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    func test_createRequest_shouldSetRequestBodyToNil() throws {
        
        let request = try createRequest()
        
        XCTAssertNil(request.httpBody)
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        _ `operator`: UtilityPaymentProvider? = nil
    ) throws -> URLRequest {
        
        try RequestFactory.createGetOperatorsListByParamOperatorOnlyFalseRequest(
            operator: `operator` ?? makeUtilityPaymentOperator()
        )
    }
}

extension XCTestCase {
    
    func makeUtilityPaymentOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        title: String = anyMessage(),
        icon: String? = anyMessage(),
        type: String = anyMessage()
    ) -> UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, type: type)
    }
}
