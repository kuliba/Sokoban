//
//  Model+PaymentsTransportAvtodorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.06.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class Model_PaymentsTransportAvtodorTests: XCTestCase {
    
    // MARK: - paymentsProcessLocalStepAvtodor: Step 0
    
    func test_paymentsProcessLocalStepAvtodor_shouldThrowOnIncorrectStep() async throws {
        
        let parameters = parametersForStep0()
        let sut = makeSUT()
        
        for stepIndex in [-2, -1, 2, 3] {
            
            try await assertThrows(
                
                try await sut.paymentsProcessLocalStepAvtodor(
                    parameters: parameters,
                    for: stepIndex
                )
            )
        }
    }
    
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
            ["iFora||AVDD", "iFora||AVDТ"]
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
            ["iFora||AVDD", "iFora||AVDТ"]
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
            ["iFora||AVDD", "iFora||AVDТ"]
        )
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldThrowOnMissingProduct_onStep0() async throws {
        
        let parameters = parametersForStep0()
        let sut = try makeSUT(serverStubs: [
            .isSingleService(.success(data: true))
        ])
        XCTAssertTrue(sut.products.value.isEmpty)
        
        try await assertThrows(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 0
            )
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.unableCreateRepresentable("ru.forabank.sense.product") as NSError
            )
        }
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

    func test_paymentsProcessLocalStepAvtodor_shouldThrowOnMissingOperatorParameter_onStep1() async throws {
        
        let parameters = parametersForStep0()
        let sut = makeSUT()
        
        try await assertThrows(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            )
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.missingParameter("ru.forabank.sense.operator") as NSError
            )
        }
        XCTAssertNil(try? parameters.parameter(forIdentifier: .operator))
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnNilValueForParameterOperator_onStep1() async throws {
        
        let parameters = parametersForStep1()
        let sut = makeSUT()
        
        try await assertThrows(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            )
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.missingValueForParameter("ru.forabank.sense.operator") as NSError
            )
        }
        
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNil(parameter.value)
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnMissingOperatorInDictionary_onStep1() async throws {
        
        let parameters = parametersForStep1(operatorParameterValue: "a3")
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNotNil(parameter.value)
        let sut = makeSUT()
        
        try await assertThrows(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            )
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.missingOperator(forCode: "a3") as NSError
            )
        }
        
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldFailOnMissingParameterList_onStep1() async throws {
        
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
        
        try await assertThrows(
            try await sut.paymentsProcessLocalStepAvtodor(
                parameters: parameters,
                for: 1
            )
        ) {
            XCTAssertNoDiff(
                $0 as NSError,
                Payments.Error.missingParameterList(forCode: "a 3") as NSError
            )
        }
        
        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNotNil(parameter.value)
        XCTAssertTrue(operatorData.parameterList.isEmpty)
    }
    
    func test_paymentsProcessLocalStepAvtodor_shouldReturnStep1_onStep1() async throws {
        
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
        
        let step = try await sut.paymentsProcessLocalStepAvtodor(
            parameters: parameters,
            for: 1
        )
        
        XCTAssertNoDiff(step.parameters.map(\.id), ["selected"])
   
        XCTAssertNoDiff(step.front.visible, ["selected"])
        XCTAssertNoDiff(step.front.isCompleted, false)

        XCTAssertNoDiff(step.back.stage, .remote(.start))
        XCTAssertNoDiff(step.back.required, ["selected"])
        XCTAssertNoDiff(step.back.processed, nil)

        let parameter = try parameters.parameter(forIdentifier: .operator)
        XCTAssertNotNil(parameter.value)
        XCTAssertFalse(operatorData.parameterList.isEmpty)
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
    
    private final class ServerAgentSpy: ServerAgentProtocol {
        
        private(set) var isSingleServiceRequestsPurefs = [String]()
        private let isSingleService: Bool?
        
        init(isSingleService: Bool?) {
            
            self.isSingleService = isSingleService
        }
        
        func executeCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerCommand {
            
            switch command {
            case let command as ServerAgentTestStub.IsSingleService:
                
                if let puref = command.payload?.puref {
                    
                    isSingleServiceRequestsPurefs.append(puref)
                }
                let response = ServerCommands.TransferController.IsSingleService.Response(statusCode: .ok, errorMessage: nil, data: isSingleService)
                completion(.success(response as! Command.Response))
            default:
                completion(.failure(.emptyResponse))
            }
        }
        
        func executeDownloadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerDownloadCommand {
            
            fatalError("unimplemented")
        }
        
        func executeUploadCommand<Command>(command: Command, completion: @escaping (Result<Command.Response, ServerAgentError>) -> Void) where Command : ServerUploadCommand {
            
            fatalError("unimplemented")
        }
        
        let action = PassthroughSubject<Action, Never>()
    }
}

extension LocalAgentStub {
    
    convenience init<T: Encodable>(
        type: T.Type = T.self,
        value: T
    ) throws {
        
        let key = "\(type.self)"
        let data = try JSONEncoder().encode(value)
        
        self.init(stub: [key: data])
    }
}

extension OperatorGroupData {
    
    static func test(
        city: String? = nil,
        code: String,
        isGroup: Bool = false,
        logotypeList: [LogotypeData] = [],
        name: String,
        operators: [OperatorData] = [],
        region: String? = nil,
        synonymList: [String] = []
    ) -> Self {
        
        .init(
            city: city,
            code: code,
            isGroup: isGroup,
            logotypeList: logotypeList,
            name: name,
            operators: operators,
            region: region,
            synonymList: synonymList
        )
    }
}

extension OperatorGroupData.OperatorData {
        
    static func test(
        city: String? = nil,
        code: String,
        isGroup: Bool = false,
        logotypeList: [OperatorGroupData.LogotypeData] = [],
        name: String,
        parameterList: [ParameterData] = [],
        parentCode: String,
        region: String? = nil,
        synonymList: [String] = []
    ) -> Self {
        
        .init(
            city: city,
            code: code,
            isGroup: isGroup,
            logotypeList: logotypeList,
            name: name,
            parameterList: parameterList,
            parentCode: parentCode,
            region: region,
            synonymList: synonymList
        )
    }
}
