//
//  RootViewModelFactory+getProviderServicePickerNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getProviderServicePickerNavigationTests: RootViewModelFactoryTests {
    
    func test_shouldDeliverOutsideMainOnOutsideMain() {
        
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: .outside(.main),
            notify: { _ in }
        ) {
            switch $0 {
            case .outside(.main):
                break
                
            default:
                XCTFail("Expected outside main, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverOutsidePaymentsOnOutsidePayments() {
        
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: .outside(.payments),
            notify: { _ in }
        ) {
            switch $0 {
            case .outside(.payments):
                break
                
            default:
                XCTFail("Expected outside payments, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverFailureOnMissingProduct() {
        
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: .service(makeServicePayload()),
            notify: { _ in }
        ) {
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure, .connectivityError)
                
            default:
                XCTFail("Expected failure, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldNotCallHTTPClientOnMissingProduct() {
        
        let (sut, httpClient, _) = makeSUT()
        XCTAssertEqual(httpClient.callCount, 0)
        
        sut.getProviderServicePickerNavigation(
            select: .service(makeServicePayload()),
            notify: { _ in },
            completion: { _ in }
        )
        
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    func test_shouldCallHTTPClientWithPayload() {
        
        let payload = makeServicePayload()
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        
        sut.getProviderServicePickerNavigation(
            select: .service(payload),
            notify: { _ in },
            completion: { _ in }
        )

        XCTAssertNoDiff(httpClient.lastPathComponentsWithQueryValue(for: ""), [
            "createAnywayTransfer"
        ])
        try XCTAssertNoDiff(httpClient.getQueryItems(),[[
            .init(name: "isNewPayment", value: "true")
        ]])
    }
    
    func test_shouldDeliverFailureOnHTTPClientFailure() {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: .service(makeServicePayload()),
            notify: { _ in }
        ) {
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure, .connectivityError)
                
            default:
                XCTFail("Expected failure, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverFailureOnHTTPClientServerError() {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: .service(makeServicePayload()),
            notify: { _ in }
        ) {
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure, .serverError("Возникла техническая ошибка"))
                
            default:
                XCTFail("Expected failure, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(withString: .serverErrorJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverSuccessOnHTTPClientSuccess() {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: .service(makeServicePayload()),
            notify: { _ in }
        ) {
            switch $0 {
            case .payment:
                break
                
            default:
                XCTFail("Expected success, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(withString: .createAnywayTransferIsNewPaymentTrueResponse)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = ProviderServicePickerDomain
    private typealias Select = Domain.Select
    private typealias NotifySpy = CallSpy<Domain.NotifyEvent, Void>
    
    private func makeServicePayload(
        service: UtilityService? = nil,
        isOneOf: Bool = .random(),
        operator: UtilityPaymentOperator? = nil
    ) -> Select.ServicePayload {
        
        return .init(
            item: .init(
                service: service ?? makeUtilityService(),
                isOneOf: isOneOf
            ),
            operator: `operator` ?? makeUtilityPaymentOperator()
        )
    }
}

extension HTTPClientSpy {
    
    func getQueryItems() throws -> [[URLQueryItem]] {
        
        try requests.map { try $0.queryItems() }
    }
}

extension String {
    
    static let serverErrorJSON = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
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
