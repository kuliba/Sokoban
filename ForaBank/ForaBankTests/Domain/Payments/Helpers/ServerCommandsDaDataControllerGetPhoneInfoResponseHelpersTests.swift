//
//  ServerCommandsDaDataControllerGetPhoneInfoResponseHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import ForaBank
import XCTest

final class ServerCommandsDaDataControllerGetPhoneInfoResponseHelpersTests: XCTestCase {

    typealias Response = ServerCommands.DaDataController.GetPhoneInfo.Response
    
    func test_errorResponse() {
        
        let errorResponse = Response.error
        
        XCTAssertEqual(errorResponse.statusCode, .error(102))
        XCTAssertEqual(errorResponse.errorMessage, "На данный момент нет возможности оплатить мобильную связь \"Тинькофф Мобайл\" ООО")
        XCTAssertEqual(errorResponse.data, nil)
    }
    
    func test_dateResponse_iFora4285() {
        
        let errorResponse = Response.data(.iFora4285)
        
        XCTAssertEqual(errorResponse.statusCode, .ok)
        XCTAssertEqual(errorResponse.errorMessage, nil)
        XCTAssertEqual(errorResponse.data, [.iFora4285])
    }
    
    func test_dateResponse_iFora4286() {
        
        let errorResponse = Response.data(.iFora4285)
        
        XCTAssertEqual(errorResponse.statusCode, .ok)
        XCTAssertEqual(errorResponse.errorMessage, nil)
        XCTAssertEqual(errorResponse.data, [.iFora4285])
    }
}

extension ServerCommands.DaDataController.GetPhoneInfo.Response {
    
    /// Error response
    ///
    /// REQUEST:
    /// {
    ///   "phoneNumbersList" : [
    ///     "79126942258"
    ///   ]
    /// }
    ///
    /// RESPONSE:
    /// {
    ///   "statusCode" : 102,
    ///   "errorMessage" : "На данный момент нет возможности оплатить мобильную связь \"Тинькофф Мобайл\" ООО",
    ///   "data" : null
    /// }
    static let error: Self = .init(
        statusCode: .error(102),
        errorMessage: "На данный момент нет возможности оплатить мобильную связь \"Тинькофф Мобайл\" ООО",
        data: nil
    )
    
    static func data(_ daData: DaDataPhoneData) -> Self {
        .init(
            statusCode: .ok,
            errorMessage: nil,
            data: [daData]
        )
    }
}
