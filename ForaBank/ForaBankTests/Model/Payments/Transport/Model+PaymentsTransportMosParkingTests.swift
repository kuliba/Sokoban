//
//  Model+PaymentsTransportMosParkingTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.06.2023.
//

@testable import ForaBank
import ServerAgent
import XCTest

//  Model+PaymentsTransportMosParking.swift
extension Model {
    
    func paymentsProcessLocalStepMosParking(
        parameters: [PaymentsParameterRepresentable],
        for stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        
        switch stepIndex {
        case 0:
            
            // useless call
            _ = try await isSingleService(Purefs.iVortexMosParking)
            
            let mosParkingListData = try await getMosParkingList()
            
            // MARK: WIP
            // let mosParkingParameter = Payments.ParameterMosParking(mosParkingListData)
            
            throw Payments.Error.unsupported
            
        default:
            throw Payments.Error.unsupported
        }
    }
    
    // MARK: - Helpers
    
    func getMosParkingList() async throws -> ServerCommands.DictionaryController.GetMosParkingList.Response.MosParkingListData {
        
        guard let token else {
            
            throw Payments.Error.notAuthorized
        }
        
        let command = ServerCommands.DictionaryController.GetMosParkingList(token: token, serial: nil)
        
        return try await serverAgent.executeCommand(command: command)
    }
}

final class Model_PaymentsTransportMosParkingTests: XCTestCase {
    
    // MARK: - paymentsProcessLocalStepMosParking
    
    func test_paymentsProcessLocalStepMosParking_shouldThrowOnIncorrectStep() async throws {
        
        let parameters = parametersForStep0()
        let sut = makeSUT()
        
        for stepIndex in [-2, -1, 1, 2, 3] {
            
            try await assertThrowsAsNSError(
                try await sut.paymentsProcessLocalStepMosParking(
                    parameters: parameters,
                    for: stepIndex
                ),
                error: Payments.Error.unsupported 
            )
        }
    }
    
    func test_paymentsProcessLocalStepMosParking_shouldCallIsSingleService_onStep0_false() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: false)
        let parameters = parametersForStep0()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepMosParking(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            [Purefs.iVortexMosParking]
        )
    }
    
    func test_paymentsProcessLocalStepMosParking_shouldCallIsSingleService_onStep0_true() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: true)
        let parameters = parametersForStep0()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepMosParking(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            [Purefs.iVortexMosParking]
        )
    }
    
    func test_paymentsProcessLocalStepMosParking_shouldCallIsSingleService_onStep0_nil() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: nil)
        let parameters = parametersForStep0()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepMosParking(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.isSingleServiceRequestsPurefs,
            [Purefs.iVortexMosParking]
        )
    }
    
    func test_paymentsProcessLocalStepMosParking_shouldCallGetMosParkingList_onStep0() async throws {
        
        let serverAgentSpy = ServerAgentSpy(isSingleService: true)
        let parameters = parametersForStep0()
        let sut = makeSUT(
            serverAgent: serverAgentSpy
        )
        
        _ = try? await sut.paymentsProcessLocalStepMosParking(
            parameters: parameters,
            for: 0
        )
        
        XCTAssertNoDiff(
            serverAgentSpy.getMosParkingListRequestCount,
            1
        )
    }
    
    func test_paymentsProcessLocalStepMosParking_shouldThrowOnGetMosParkingListServerFailure_onStep0() async throws {
        
        let parameters = parametersForStep0()
        let sut = try makeSUT(serverStubs: [
            .isSingleService(.success(data: true)),
            .mosParking(.failure(.corruptedData(NSError(domain: "Bad server data", code: 0))))
        ])
        
        try await assertThrowsAsNSError(
            _ = try await sut.paymentsProcessLocalStepMosParking(
                parameters: parameters,
                for: 0
            ),
            error: ServerAgentError.corruptedData(NSError(domain: "Bad server data", code: 0))
        )
    }
    
    func test_paymentsProcessLocalStepMosParking_shouldThrowOnNilGetMosParkingList_onStep0() async throws {
        
        let parameters = parametersForStep0()
        let sut = try makeSUT(serverStubs: [
            .isSingleService(.success(data: true)),
            .mosParking(.success(data: nil))
        ])
        
        try await assertThrowsAsNSError(
            _ = try await sut.paymentsProcessLocalStepMosParking(
                parameters: parameters,
                for: 0
            ),
            error: ServerAgentError.serverStatus(.ok, errorMessage: nil)
        )
    }
    
    // MARK: WIP
    //    func test_paymentsProcessLocalStepMosParking_shouldReceiveGetMosParkingList_onStep0() async throws {
    //
    //        let parameters = parametersForStep0()
    //        let sut = try makeSUT(serverStubs: [
    //            .isSingleService(.success(data: true)),
    //            .mosParking(.success(data: .test))
    //        ])
    //
    //        _ = try? await sut.paymentsProcessLocalStepMosParking(
    //            parameters: parameters,
    //            for: 0
    //        )
    //    }
    
    // MARK: - Helpers
    
    private func parametersForStep0() -> [PaymentsParameterRepresentable] {
        
        []
    }
    
    private func makeSUT(
        serverStubs: [ServerAgentTestStub.Stub],
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let sut = makeSUT(
            serverAgent: ServerAgentTestStub(serverStubs),
            file: file,
            line: line
        )
        
        return sut
    }
    
    private func makeSUT(
        serverAgent: ServerAgentProtocol? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = serverAgent ?? ServerAgentTestStub([])
        
        let sut: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

extension ServerAgentTestStub.Stub.MosParkingResult {
    
    static func success(
        statusCode: ServerStatusCode = .ok,
        errorMessage: String? = nil,
        data: ServerAgentTestStub.MosParkingListData? = nil
    ) -> Self {
        
        .success(.init(statusCode: statusCode, errorMessage: errorMessage, data: data))
    }
    
    static func failure(
        serverAgentError: ServerAgentError = .emptyResponseData
    ) -> Self {
        
        .failure(serverAgentError)
    }
}
