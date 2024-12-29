//
//  RootViewModelFactory+processServicePayloadTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_processServicePayloadTests: RootViewModelFactoryTests {
    
    func test_shouldNotCallHTTPClientOnMissingProduct() {
        
        let (sut, httpClient, _) = makeSUT()
        XCTAssertEqual(httpClient.callCount, 0)
        
        sut.process(payload: makePayload()) { _ in }
        
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_shouldCallHTTPClientWithPayload() throws {
        
        let payload = makePayload()
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        XCTAssertEqual(httpClient.callCount, 0)
        
        sut.process(payload: payload) { _ in }
        
        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: ""), [
            "createAnywayTransfer"
        ])
        try XCTAssertNoDiff(httpClient.getQueryItems(),[[
            .init(name: "isNewPayment", value: "true")
        ]])
    }
    
    func test_shouldDeliverFailureOnHTTPClientFailure() throws {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.process(payload: makePayload()) {
            
            switch $0 {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverSuccessOnHTTPClientSuccess() throws {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.process(payload: makePayload()) {
            
            switch $0 {
            case .failure:
                XCTFail("Expected success, but got \($0) instead.")
                
            default:
                break
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(withString: .createAnywayTransferIsNewPaymentTrueResponse)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias Payload = SUT.ProcessServicePayload
    
    private func makePayload(
        service: UtilityService? = nil,
        isOneOf: Bool = .random(),
        operator: UtilityPaymentProvider? = nil
    ) -> Payload {
        
        return .init(
            item: .init(
                service: service ?? makeUtilityService(),
                isOneOf: isOneOf
            ),
            operator: `operator` ?? makeUtilityPaymentProvider()
        )
    }
}

extension HTTPClientSpy {
    
    func getQueryItems() throws -> [[URLQueryItem]] {
        
        try requests.map { try $0.queryItems() }
    }
}

extension String {
    
    static let createAnywayTransferIsNewPaymentTrueResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "additionalList": [],
        "parameterListForNextStep": [
            {
                "id": "1",
                "title": "Лицевой счет",
                "viewType": "INPUT",
                "dataType": "%Numeric",
                "type": "Input",
                "regExp": "^.{1,250}$",
                "rawLength": 0,
                "isRequired": true,
                "readOnly": false,
                "inputFieldType": "ACCOUNT",
                "visible": true,
                "md5hash": "6e17f502dae62b03d8bd4770606ee4b2"
            },
            {
                "id": "##ID##",
                "viewType": "OUTPUT",
                "content": "ffc84724-8976-4d37-8af8-be84a4386126",
                "visible": false
            },
            {
                "id": "##STEP##",
                "viewType": "OUTPUT",
                "content": "1",
                "visible": false
            }
        ]
    }
}
"""
}
