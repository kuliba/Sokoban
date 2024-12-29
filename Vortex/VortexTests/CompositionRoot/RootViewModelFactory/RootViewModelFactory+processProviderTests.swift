//
//  RootViewModelFactory+processProviderTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2024.
//

import VortexTools

// RootViewModelFactory+makePaymentProviderPicker.swift:257
/// A namespace.
enum ProcessPaymentProviderDomain<Operator, Service, StartPaymentResult> {}

extension ProcessPaymentProviderDomain {
    
    typealias Payload = Operator
    
    enum Response {
        
        /// `d3-d5`
        case operatorFailure(Operator)
        /// `d1`
        case services(MultiElementArray<Service>, for: Operator)
        /// Success: `d2, e1`, Failure: `d2, e2-e4`
        case startPayment(StartPaymentResult)
    }
}

extension ProcessPaymentProviderDomain.Response: Equatable where Operator: Equatable, Service: Equatable, StartPaymentResult: Equatable {}

extension UtilityPaymentOperator {
    
    var getServicesForPayload: RootViewModelFactory.GetServicesForPayload {
        
        return .init(operatorID: id, type: type)
    }
}

import RemoteServices

extension RootViewModelFactory {
    
    func processProvider(
        payload: ProcessPaymentProviderDomain.Payload,
        completion: @escaping (ProcessPaymentProviderDomain.Response) -> Void
    ) {
        loadServices(for: payload.getServicesForPayload) {
            
            switch ($0.first, MultiElementArray($0)) {
            case (nil, _):
                completion(.operatorFailure(payload))
                
            case let (.some(service), nil):
                break
                
            case let (_, .some(services)):
                completion(.services(services, for: payload))
            }
        }
    }
    
    typealias ProcessPaymentProviderDomain = VortexTests.ProcessPaymentProviderDomain<UtilityPaymentOperator, ServicePickerItem, Result<Void, Error>>
}

@testable import Vortex
import XCTest

final class RootViewModelFactory_processProviderTests: RootViewModelFactoryTests {
    
    func test_shouldCallHTTPClientWithGetOperatorsListByParamOperatorOnlyFalseWithPayload() throws {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        
        sut.processProvider(payload: payload) { _ in }
        
        XCTAssertNoDiff(
            httpClient.lastPathComponentsWithQueryValue(for: ""),
            ["getOperatorsListByParam"]
        )
        try XCTAssertNoDiff(httpClient.requests.map { try $0.queryItems() }, [[
            .init(name: "operatorOnly", value: "false"),
            .init(name: "customerId", value: payload.id),
            .init(name: "type", value: payload.type)
        ]])
    }
    
    func test_shouldDeliverOperatorFailureOnHTTPClientFailure() throws {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.processProvider(payload: payload) {
            
            switch $0 {
            case let .operatorFailure(`operator`):
                XCTAssertNoDiff(`operator`, payload)
                
            default:
                XCTFail("Expected `operatorFailure`, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverOperatorFailureOnHTTPClientSuccessWithNoServices() throws {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.processProvider(payload: payload) {
            
            switch $0 {
            case let .operatorFailure(`operator`):
                XCTAssertNoDiff(`operator`, payload)
                
            default:
                XCTFail("Expected `operatorFailure`, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(withString: .emptyServicesValidJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverServicesOnHTTPClientSuccessWithTwoServices() throws {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.processProvider(payload: payload) {
            
            switch $0 {
            case let .services(services, for: `operator`):
                XCTAssertNoDiff(`operator`, payload)
                XCTAssertNoDiff(services, .init(
                    .init(service: .mirnaya, isOneOf: true),
                    .init(service: .burash, isOneOf: true)
                ))
                
            default:
                XCTFail("Expected `services`, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(withString: .multiServicesValidJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = SUT.ProcessPaymentProviderDomain
    private typealias Payload = Domain.Payload
    private typealias Response = Domain.Response
    
    private func makePayload(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        title: String = anyMessage(),
        icon: String? = anyMessage(),
        type: String = anyMessage()
    ) -> Payload {
        
        return .init(id: id, inn: inn, title: title, icon: icon, type: type)
    }
}

private extension UtilityService {
    
    static let mirnaya: Self = .init(
        icon: "ef7a4271cdec35cc20c4ca0bb4d43f93",
        name: "КОММУНАЛЬНЫЕ УСЛУГИ-МИРНАЯ 3",
        puref: "iVortexNKORR||55177"
    )
    static let burash: Self = .init(
        icon: "ef7a4271cdec35cc20c4ca0bb4d43f93",
        name: "КОММУНАЛЬНЫЕ УСЛУГИ-БУРАШЕВСКОЕ Ш 62",
        puref: "iVortexNKORR||66659"
    )
}
