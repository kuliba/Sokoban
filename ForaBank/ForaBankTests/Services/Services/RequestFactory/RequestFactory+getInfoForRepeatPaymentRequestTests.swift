//
//  RequestFactory+getInfoForRepeatPaymentRequestTests.swift
//
//
//  Created by Дмитрий Савушкин on 30.07.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class RequestFactory_getInfoForRepeatPaymentRequestTests: XCTestCase {
    
    func test_createRequest_shouldSetURL() throws {
        
        let url = anyURL(string: "https://pl.forabank.ru/dbo/api/v3/rest/v1/getInfoForRepeatPayment")
        let request = try createRequest(url: url)
        
        XCTAssertNoDiff(request.url, url)
    }

    func test_createRequest_shouldSetHTTPMethodToPOST() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.httpMethod, "POST")
    }
    
    func test_createRequest_shouldSetCachePolicy() throws {
        
        let request = try createRequest()
        
        XCTAssertNoDiff(request.cachePolicy, .reloadIgnoringLocalAndRemoteCacheData)
    }
    
    func test_createRequest_shouldSetRequestBody() throws {
        
        let request = try createRequest(payload: .init(paymentOperationDetailId: 1))
        let decodedRequest = try JSONDecoder().decode(
            DecodableInfoForRepeatPaymentRequest.self,
            from: XCTUnwrap(request.httpBody)
        )
        
        XCTAssertNoDiff(decodedRequest.paymentOperationDetailId, "1")
    }
    
    // MARK: - Helpers
    
    private func createRequest(
        url: URL = anyURL(),
        payload: InfoForRepeatPaymentPayload = anyPayload()
    ) throws -> URLRequest {
        
        return RequestFactory.getInfoForRepeatPayment(payload)
    }
    
    private struct DecodableInfoForRepeatPaymentRequest: Decodable {
        
        let paymentOperationDetailId: String
        
        init(infoForRepeatPayment: InfoForRepeatPaymentPayload) {
            
            self.paymentOperationDetailId = "\(infoForRepeatPayment.paymentOperationDetailId)"
        }
    }
}

private func anyPayload(
    paymentOperationDetailId: Int = 1
) -> InfoForRepeatPaymentPayload {
    
    return .init(paymentOperationDetailId: paymentOperationDetailId)
}
