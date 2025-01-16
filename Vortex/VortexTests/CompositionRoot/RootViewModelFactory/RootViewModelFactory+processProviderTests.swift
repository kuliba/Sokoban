//
//  RootViewModelFactory+processProviderTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_processProviderTests: RootViewModelFactoryTests {
    
    func test_shouldCallHTTPClientWithGetOperatorsListByParamOperatorOnlyFalseWithPayload() throws {
        
        let (payload, response) = (makePayload(), makeServiceResponse())
        let (sut, httpClient, _) = makeSUT()
        
        sut.processProvider(payload: payload, processService: { $1(response) }) { _ in }
        
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
        
        expect(sut, payload, toDeliver: .operatorFailure(payload)) {
            
            httpClient.complete(with: anyError())
        }
    }
    
    func test_shouldDeliverOperatorFailureOnHTTPClientSuccessWithNoServices() throws {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        
        expect(sut, payload, toDeliver: .operatorFailure(payload)) {
            
            httpClient.complete(withString: .emptyServicesValidJSON)
        }
    }
    
    func test_shouldCallProcessServiceWithServiceOnHTTPClientSuccessWithOneService() throws {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        let processServiceSpy = ProcessServiceSpy()
        
        let exp = expectation(description: "wait for completion")
        
        sut.processProvider(
            payload: payload,
            processService: processServiceSpy.processSuccess
        ) { _ in exp.fulfill() }
        
        httpClient.complete(withString: .singleServiceValidJSON)
        processServiceSpy.complete(with: makeServiceResponse())
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(processServiceSpy.payloads, [
            .init(service: .capremont, isOneOf: false)
        ])
    }
    
    func test_shouldDeliverStartPaymentOnHTTPClientSuccessWithOneService() throws {
        
        let response = makeServiceResponse()
        let (sut, httpClient, _) = makeSUT()
        let processServiceSpy = ProcessServiceSpy()
        
        expect(
            sut,
            processService: processServiceSpy.processSuccess,
            makePayload(),
            toDeliver: .startPayment(response)
        ) {
            httpClient.complete(withString: .singleServiceValidJSON)
            processServiceSpy.complete(with: response)
        }
    }
    
    func test_shouldDeliverServicesOnHTTPClientSuccessWithTwoServices() throws {
        
        let payload = makePayload()
        let (sut, httpClient, _) = makeSUT()
        
        expect(
            sut,
            payload,
            toDeliver: .services(
                .init(
                    .init(service: .mirnaya, isOneOf: true),
                    .init(service: .burash, isOneOf: true)
                ),
                for: payload
            )
        ) {
            httpClient.complete(withString: .multiServicesValidJSON)
        }
    }
    
    // MARK: - Helpers
    
    private typealias Domain = SUT.ProcessPaymentProviderDomain<ServiceResponse>
    private typealias Payload = Domain.Payload
    private typealias Response = Domain.Response
    private typealias ProcessServiceSpy = Spy<ServicePickerItem, ServiceResponse, Never>
    
    private func makePayload(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        title: String = anyMessage(),
        icon: String? = anyMessage(),
        type: String = anyMessage()
    ) -> Payload {
        
        return .init(id: id, inn: inn, title: title, icon: icon, type: type)
    }
    
    private struct ServiceResponse: Equatable {
        
        let value: String
    }
    
    private func makeServiceResponse(
        _ value: String = anyMessage()
    ) -> ServiceResponse {
        
        return .init(value: value)
    }
    
    private func expect(
        _ sut: SUT,
        processService: @escaping (ServicePickerItem, @escaping (ServiceResponse) -> Void) -> Void = { _,_ in },
        _ payload: Domain.Payload,
        toDeliver expectedResponse: Domain.Response,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.processProvider(
            payload: payload,
            processService: processService
        ) {
            XCTAssertNoDiff($0, expectedResponse, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
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
    static let capremont: Self = .init(
        icon: "ef7a4271cdec35cc20c4ca0bb4d43f93",
        name: "КАПРЕМОНТ (Р/С ...00024)",
        puref: "iVortexNKORR||42358"
    )
}
