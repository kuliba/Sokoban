//
//  MicroServices+ContractMakerTests.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import FastPaymentsSettings
import XCTest

final class MicroServices_ContractMakerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, createContractSpy, getContractSpy) = makeSUT()
        
        XCTAssertEqual(createContractSpy.callCount, 0)
        XCTAssertEqual(getContractSpy.callCount, 0)
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_createContractConnectivityErrorFailure() {
        
        let (sut, createContractSpy, _) = makeSUT()
        
        expect(sut, with: makePayload(), toDeliver: .failure(.connectivityError), on: {
            
            createContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_process_shouldDeliverServerErrorOn_createContractServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, createContractSpy, _) = makeSUT()
        
        expect(sut, with: makePayload(), toDeliver: .failure(.serverError(message)), on: {
            
            createContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractConnectivityErrorFailure() {
        
        let (sut, createContractSpy, getContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(), toDeliver: .failure(.connectivityError), on: {
            
            createContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_process_shouldDeliverServerErrorOn_getContractServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, createContractSpy, getContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(), toDeliver: .failure(.serverError(message)), on: {
            
            createContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractSuccessNil() {
        
        let (sut, createContractSpy, getContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(), toDeliver: .failure(.connectivityError), on: {
            
            createContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(nil))
        })
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractSuccessInactive() {
        
        let inactive = makeContract(status: .inactive)
        let (sut, createContractSpy, getContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(), toDeliver: .failure(.connectivityError), on: {
            
            createContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(inactive))
        })
    }
    
    func test_process_shouldDeliverContractOn_getContractSuccessActive() {
        
        let active = makeContract(status: .active)
        let (sut, createContractSpy, getContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(), toDeliver: .success(active), on: {
            
            createContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(active))
        })
    }
    
    func test_process_shouldNotDeliverCreateContractResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let createContractSpy: CreateContractSpy
        (sut, createContractSpy, _) = makeSUT()
        var receivedResult: SUT.ProcessResult?
        
        sut?.process(makePayload()) { receivedResult = $0 }
        sut = nil
        createContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNil(receivedResult)
    }
    
    func test_process_shouldNotDeliverGetContractResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let createContractSpy: CreateContractSpy
        let getContractSpy: GetContractSpy
        (sut, createContractSpy, getContractSpy) = makeSUT()
        var receivedResult: SUT.ProcessResult?
        
        sut?.process(makePayload()) { receivedResult = $0 }
        createContractSpy.complete(with: .success(()))
        sut = nil
        getContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNil(receivedResult)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.ContractMaker<Payload, Contract>
    
    private typealias CreateContractSpy = Spy<Payload, SUT.CreateContractResponse>
    private typealias GetContractSpy = Spy<Void, SUT.GetContractResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        createContractSpy: CreateContractSpy,
        getContractSpy: GetContractSpy
    ) {
        let createContractSpy = CreateContractSpy()
        let getContractSpy = GetContractSpy()
        
        let sut = SUT(
            createContract: createContractSpy.process(_:completion:),
            getContract: getContractSpy.process(completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(createContractSpy, file: file, line: line)
        trackForMemoryLeaks(getContractSpy, file: file, line: line)
        
        return (sut, createContractSpy, getContractSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with payload: Payload,
        toDeliver expected: SUT.ProcessResult,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process(payload) {
            
            XCTAssertNoDiff($0, expected, "\nExpected \(expected), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    private struct Contract: Equatable, StatusReporting {
        
        let value: String
        let status: ContractStatus
    }
    
    private struct Payload: Equatable {
        
        var value: UUID
    }
    
    private func makeContract(
        _ value: String = UUID().uuidString,
        status: ContractStatus
    ) -> Contract {
        
        .init(value: value, status: status)
    }
    
    private func makePayload(
        _ value: UUID = .init()
    ) -> Payload {
        
        .init(value: value)
    }
}
