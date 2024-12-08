//
//  Model+PaymentsTransportGibddTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 20.06.2023.
//

@testable import Vortex
import XCTest

final class Model_PaymentsTransportGibddTests: XCTestCase {
    
    // MARK: - paymentsProcessLocalStepGibdd - Step 0
    
    func test_paymentsProcessLocalStepGibdd_shouldCallIsSingleService_onStep0() async throws {
        
        let spy = ServerAgentSpy(isSingleService: true)
        let sut = makeSUT(serverAgent: spy)
        
        _ = try? await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        XCTAssertNoDiff(spy.isSingleServiceRequestsPurefs, [Purefs.iVortexGibdd])
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldFailOnFailingIsSingleService_onStep0() async throws {
        
        let stub = ServerAgentTestStub([
            .isSingleService(.failure())
        ])
        let sut = makeSUT(serverAgent: stub)
        
        try await assertThrowsAsNSError(
            _ = try await sut.paymentsProcessLocalStepGibdd(
                parameters: [],
                for: 0
            ),
            error: Payments.Error.isSingleService.serverCommandError(error: "")
        )
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldFailOnIsSingleServiceReturningNil_onStep0() async throws {
        
        let stub = ServerAgentTestStub([
            .isSingleService(.success(data: nil))
        ])
        let sut = makeSUT(serverAgent: stub)
        
        try await assertThrowsAsNSError(
            _ = try await sut.paymentsProcessLocalStepGibdd(
                parameters: [],
                for: 0
            ),
            error: Payments.Error.isSingleService.emptyData(message: nil)
        )
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldFailOnIsSingleServiceReturningTrue_onStep0() async throws {
        
        let stub = ServerAgentTestStub([
            .isSingleService(.success(data: true))
        ])
        let sut = makeSUT(serverAgent: stub)
        
        try await assertThrowsAsNSError(
            _ = try await sut.paymentsProcessLocalStepGibdd(
                parameters: [],
                for: 0
            ),
            error: Payments.Error.unexpectedIsSingleService
        )
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldFailOnMissingProductOnIsSingleServiceReturningFalse_onStep0() async throws {
        
        let stub = ServerAgentTestStub([
            .isSingleService(.success(data: false))
        ])
        let sut = makeSUT(serverAgent: stub)
        
        try await assertThrowsAsNSError(
            _ = try await sut.paymentsProcessLocalStepGibdd(
                parameters: [],
                for: 0
            ),
            error: Payments.Error.unableCreateRepresentable("ru.vortex.sense.product")
        )
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldSetStepParameters_onStep0() async throws {
        
        let sut = makeSUT(
            serverStubs: [
                .isSingleService(.success(data: false))
            ],
            products: makeProductsData([(.card, 1)])
        )
        
        let step = try await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        XCTAssertNoDiff(step.parameters.map(\.id), [
            "ru.vortex.sense.operator",
            "ru.vortex.sense.header",
            "ru.vortex.sense.product",
            "a3_SearchType_1_1"
        ])
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldSetStepParameterOperator_onStep0() async throws {
        
        let sut = makeSUT(
            serverStubs: [
                .isSingleService(.success(data: false))
            ],
            products: makeProductsData([(.card, 1)])
        )
        
        let step = try await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        let parameter = try XCTUnwrap(step.parameters[0] as? Payments.ParameterOperator)
        XCTAssertNoDiff(parameter.id, "ru.vortex.sense.operator")
        XCTAssertNoDiff(parameter.value, Purefs.iVortexGibdd)
        XCTAssertNoDiff(parameter.operator,.gibdd)
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldSetStepParameterHeader_onStep0() async throws {
        
        let sut = makeSUT(
            serverStubs: [
                .isSingleService(.success(data: false))
            ],
            products: makeProductsData([(.card, 1)])
        )
        
        let step = try await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        let parameter = try XCTUnwrap(step.parameters[1] as? Payments.ParameterHeader)
        XCTAssertNoDiff(parameter.id, "ru.vortex.sense.header")
        XCTAssertNoDiff(parameter.value, "ru.vortex.sense.header")
        XCTAssertNoDiff(parameter.title, "Штрафы ГИБДД")
        XCTAssertNoDiff(parameter.subtitle, nil)
        XCTAssertNoDiff(parameter.style, .normal)
        XCTAssertNoDiff(parameter.placement, .top)
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldSetStepParameterProduct_onStep0() async throws {
        
        let sut = makeSUT(
            serverStubs: [
                .isSingleService(.success(data: false))
            ],
            products: makeProductsData([(.card, 1)])
        )
        
        let step = try await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        let parameter = try XCTUnwrap(step.parameters[2] as? Payments.ParameterProduct)
        XCTAssertNoDiff(parameter.id, "ru.vortex.sense.product")
        XCTAssertNoDiff(parameter.value, "0")
        XCTAssertNoDiff(parameter.title, "Счет списания")
        XCTAssertNoDiff(parameter.isEditable, true)
        XCTAssertNoDiff(parameter.group, nil)
        XCTAssertNoDiff(parameter.productId, 0)
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldSetStepParameterSelect_onStep0() async throws {
        
        let sut = makeSUT(
            serverStubs: [
                .isSingleService(.success(data: false))
            ],
            products: makeProductsData([(.card, 1)])
        )
        
        let step = try await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        let parameter = step.parameters[3]
        XCTAssertNoDiff(parameter.id, "a3_SearchType_1_1")
        XCTAssertNoDiff(parameter.value, "20")
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldReturnCompletedVisibleFront_onStep0() async throws {
        
        let sut = makeSUT(
            serverStubs: [
                .isSingleService(.success(data: false))
            ],
            products: makeProductsData([(.card, 1)])
        )
        
        let step = try await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        XCTAssertNoDiff(step.front.visible, [
            "ru.vortex.sense.header",
            "a3_SearchType_1_1"
        ])
        XCTAssertNoDiff(step.front.isCompleted, true)
    }
    
    func test_paymentsProcessLocalStepGibdd_shouldReturnRemoteStartStepWithSelectBack_onStep0() async throws {
        
        let sut = makeSUT(
            serverStubs: [
                .isSingleService(.success(data: false))
            ],
            products: makeProductsData([(.card, 1)])
        )

        let step = try await sut.paymentsProcessLocalStepGibdd(
            parameters: [],
            for: 0
        )
        
        XCTAssertNoDiff(step.back.stage, .remote(.start))
        XCTAssertNoDiff(step.back.required, ["a3_SearchType_1_1"])
        XCTAssertNoDiff(step.back.processed, nil)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        serverStubs: [ServerAgentTestStub.Stub] = [],
        products: ProductsData = [:],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut = makeSUT(
            serverAgent: ServerAgentTestStub(serverStubs),
            file: file,
            line: line
        )
        
        sut.products.value = products
        
        return sut
    }
    
    private func makeSUT(
        serverAgent: ServerAgentProtocol? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: ActiveSessionAgentStub(),
            serverAgent: serverAgent ?? ServerAgentEmptyMock()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
