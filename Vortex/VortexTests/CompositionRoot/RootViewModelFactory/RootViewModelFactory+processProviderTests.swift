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
    
    // de facto payload for createGetOperatorsListByParamOperatorOnlyFalseRequest without serial (which is intentionally ignored)
    struct Payload: Equatable {
        
        let id: String
        let type: String
    }
    
    enum Response {
        
        /// `d3-d5`
        case operatorFailure(Operator)
        /// `d1`
        case services(MultiElementArray<Service>, for: Operator)
        /// Success: `d2, e1`, Failure: `d2, e2-e4`
        case startPayment(StartPaymentResult)
    }
}

extension ProcessPaymentProviderDomain.Payload {
    
    /// - Warning: `serial` is intentionally ignored.
    var getOperatorsPayload: Vortex.RequestFactory.GetOperatorsListByParamOperatorOnlyFalsePayload {
        
        return .init(operatorID: id, type: type, serial: nil)
    }
    
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
        loadServices(for: payload.getServicesForPayload) { _ in }
    }
    
    typealias ProcessPaymentProviderDomain = VortexTests.ProcessPaymentProviderDomain<UtilityPaymentOperator, UtilityService, Result<Void, Error>>
    
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
    
    // MARK: - Helpers
    
    private typealias Domain = SUT.ProcessPaymentProviderDomain
    private typealias Payload = Domain.Payload
    private typealias Response = Domain.Response
    
    private func makePayload(
        id: String = anyMessage(),
        type: String = anyMessage()
    ) -> Payload {
        
        return .init(id: id, type: type)
    }
}
