//
//  Model+PaymentsTransportAvtodorTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 18.06.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class Model_PaymentsTransportAvtodorTests: XCTestCase {
    
    func test_paymentsProcessLocalStepAvtodor_shouldThrowOnIncorrectStep() async throws {
        
        let parameters = parametersForStep0()
        let sut = makeSUT()
        
        for stepIndex in [-2, -1, 3, 4] {
            
            try await assertThrowsAsNSError(
                try await sut.paymentsProcessLocalStepAvtodor(
                    parameters: parameters,
                    for: stepIndex
                ),
                error: Payments.Error.unsupported
            )
        }
    }
    
    // MARK: - paymentsProcessLocalStepAvtodor: Step 0
    
    func test_paymentsProcessLocalStepAvtodor_shouldCallIsSingleService_onStep0_false() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: false)
        let parameters = parametersForStep0()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            [Purefs.avtodorContract, Purefs.avtodorTransponder]
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldCallIsSingleService_onStep0_true() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: true)
        let parameters = parametersForStep0()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            [Purefs.avtodorContract, Purefs.avtodorTransponder]
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnIsSingleService_onStep0_nil() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: nil)
        let parameters = parametersForStep0()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNotEqual(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            [Purefs.avtodorContract, Purefs.avtodorTransponder]
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldThrowOnMissingProduct_onStep0() async throws {
        
        let parameters = parametersForStep0()
        let sut = try makeSUT(serverStubs: [
            .isSingleService(.success(data: true))
        ])
        XCTAssertTrue(sut.products.value.isEmpty)
        
        try await assertThrowsAsNSError(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 0
            ),
            error: Payments.Error.unableCreateRepresentable("ru.forabank.sense.product")
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldReturnStep0_onStep0() async throws {
        
        let parameters = parametersForStep0()
        let sut = try makeSUT(
            serverStubs: [
                .isSingleService(.success(data: true))
            ],
            products: makeProductsData([(.card, 1)])
        )
        
        let step = try await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNoDiff(step.parameters.map(\.id), [
            "ru.forabank.sense.header",
            "ru.forabank.sense.product",
            "ru.forabank.sense.operator"
        ])
        
        XCTAssertNoDiff(step.front.visible, [
            "ru.forabank.sense.header",
            "ru.forabank.sense.operator"
        ])
        XCTAssertNoDiff(step.front.isCompleted, true)
        
        XCTAssertNoDiff(step.back.stage, .local)
        XCTAssertNoDiff(step.back.required, [
            "ru.forabank.sense.operator"
        ])
        XCTAssertNoDiff(step.back.processed, nil)
        
        XCTAssertNoDiff(
            sut.products.value.mapValues(\.count),
            [.card: 1]
        )
    }
    
    // MARK: - paymentsProcessLocalStepAvtodor: Step 1
    
    func test_paymentsProcessLocalStepAvtodor_shouldNotCallIsSingleService_onStep1_false() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: false)
        let parameters = parametersForStep1()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 1
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            []
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldNotCallIsSingleService_onStep1_true() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: true)
        let parameters = parametersForStep1()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 1
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            []
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldNotCallIsSingleService_onStep1_nil() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: nil)
        let parameters = parametersForStep1()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 1
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            []
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldThrowOnMissingOperatorParameter_onStep1() async throws {
        
        let parameters = parametersForStep1()
        let sut = makeSUT()
        
        try await assertThrowsAsNSError(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            ),
            error: Payments.Error.missingValueForParameter("ru.forabank.sense.operator")
        )
        
        XCTAssertNil(try? parameters.parameter(forIdentifier: .operator).value)
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnNilValueForParameterOperator_onStep1() async throws {
        
        let parameters = parametersForStep1()
        let sut = makeSUT()
        
        try await assertThrowsAsNSError(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            ),
            error: Payments.Error.missingValueForParameter("ru.forabank.sense.operator")
        )
        
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNil(parameter.value)
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnMissingOperatorInDictionary_onStep1() async throws {
        
        let parameters = parametersForStep1(operatorParameterValue: "a3")
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNotNil(parameter.value)
        let sut = makeSUT()
        
        try await assertThrowsAsNSError(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            ),
            error: Payments.Error.missingOperator(forCode: "a3")
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnEmptyParameterList_onStep1() async throws {
        
        let operatorData = OperatorGroupData.OperatorData.test(
            code: "a3",
            name: "AVDD",
            parentCode: "AVD"
        )
        let operatorGroupData = OperatorGroupData.test(
            code: "AVD",
            name: "Avtodor",
            operators: [operatorData]
        )
        let sut = try makeSUT(
            locaStubs: [operatorGroupData]
        )
        let parameters = parametersForStep1(operatorParameterValue: "a3")
        
        try await assertThrowsAsNSError(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            ),
            error: Payments.Error.emptyParameterList(forType: "Input")
        )
        
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNotNil(parameter.value)
        XCTAssertTrue(operatorData.parameterList.filter({ $0.type == "Input" }).isEmpty)
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnParameterListWithoutInput_onStep1() async throws {
        
        let operatorData = OperatorGroupData.OperatorData.test(
            code: "a3",
            name: "AVDD",
            parameterList: [
                .test(id: "selected", rawLength: 5, title: "A")
            ],
            parentCode: "AVD"
        )
        let operatorGroupData = OperatorGroupData.test(
            code: "AVD",
            name: "Avtodor",
            operators: [operatorData]
        )
        let sut = try makeSUT(
            locaStubs: [operatorGroupData]
        )
        let parameters = parametersForStep1(operatorParameterValue: "a3")
        
        try await assertThrowsAsNSError(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            ),
            error: Payments.Error.emptyParameterList(forType: "Input")
        )
        
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNotNil(parameter.value)
        XCTAssertTrue(operatorData.parameterList.filter({ $0.type == "Input" }).isEmpty)
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldReturnStep_onStep1() async throws {
        
        let operatorData = OperatorGroupData.OperatorData.test(
            code: "a3",
            name: "AVDD",
            parameterList: [
                .test(id: "selected", rawLength: 5, title: "A", type: "Input")
            ],
            parentCode: "AVD"
        )
        let operatorGroupData = OperatorGroupData.test(
            code: "AVD",
            name: "Avtodor",
            operators: [operatorData]
        )
        let sut = try makeSUT(
            locaStubs: [operatorGroupData]
        )
        let parameters = parametersForStep1(operatorParameterValue: "a3")
        
        let step = try await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 1
        )
        
        XCTAssertNoDiff(step.parameters.map(\.id), ["selected"])
        
        XCTAssertNoDiff(step.front.visible, ["selected"])
        XCTAssertNoDiff(step.front.isCompleted, false)
        
        XCTAssertNoDiff(step.back.stage, .local)
        XCTAssertNoDiff(step.back.required, ["selected"])
        XCTAssertNoDiff(step.back.processed, nil)
        
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNotNil(parameter.value)
        XCTAssertFalse(operatorData.parameterList.filter({ $0.type == "Input" }).isEmpty)
    }
        
    // MARK: - paymentsProcessLocalStepAvtodor: Step 2
    
    func test_paymentsProcessLocalStepAvtodor_shouldNotCallIsSingleService_onStep2_false() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: false)
        let parameters = parametersForStep2()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 2
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            []
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldNotCallIsSingleService_onStep2_true() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: true)
        let parameters = parametersForStep2()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 2
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            []
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldNotCallIsSingleService_onStep2_nil() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: nil)
        let parameters = parametersForStep2()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 2
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            []
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldReturnStepWithAmount_onStep2() async throws {
        
        let sut = makeSUT()
        let parameters = parametersForStep2(operatorParameterValue: "a3")
        
        let step = try await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 2
        )
        
        XCTAssertNoDiff(step.parameters.map(\.id), ["ru.forabank.sense.amount"])
        
        XCTAssertNoDiff(step.front.visible, ["ru.forabank.sense.amount"])
        XCTAssertNoDiff(step.front.isCompleted, false)
        
        XCTAssertNoDiff(step.back.stage, .remote(.start))
        XCTAssertNoDiff(step.back.required, ["ru.forabank.sense.amount"])
        XCTAssertNoDiff(step.back.processed, nil)
    }
        
    // MARK: - Helpers
    
    private func parametersForStep0() -> [PaymentsParameterRepresentable] {
        
        Payments.Operation(service: .avtodor).parameters
    }
    
    private func parametersForStep1(
        operatorParameterValue: String? = nil
    ) -> [PaymentsParameterRepresentable] {
        
        let operatorParameter = Payments.ParameterMock(
            id: Payments.Parameter.Identifier.operator.rawValue,
            value: operatorParameterValue
        )
        
        return [
            // header
            // product
            operatorParameter
        ]
    }
    
    private func parametersForStep2(
        operatorParameterValue: String? = nil
    ) -> [PaymentsParameterRepresentable] {
        
        let inputParameter = Payments.ParameterInput(
            .init(
                id: "input",
                value: ""
            ),
            title: "Enter data",
            validator: .init(rules: [])
        )
        
        return [inputParameter]
    }
    
    private func makeSUT(
        serverStubs: [ServerAgentTestStub.Stub] = [],
        products: ProductsData = [:],
        locaStubs: [OperatorGroupData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let sut = makeSUT(
            serverAgent: ServerAgentTestStub(serverStubs),
            localAgent: try LocalAgentStub(value: locaStubs),
            file: file,
            line: line
        )
        
        sut.products.value = products
        
        return sut
    }
    
    private func makeSUT(
        serverAgent: ServerAgentProtocol? = nil,
        localAgent: LocalAgentProtocol? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = serverAgent ?? ServerAgentTestStub([])
        let localAgent = localAgent ?? LocalAgentStub(stub: [:])
        
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent,
            localAgent: localAgent
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
