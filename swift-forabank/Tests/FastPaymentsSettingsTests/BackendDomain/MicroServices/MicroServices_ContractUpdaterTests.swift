//
//  MicroServices+ContractUpdaterTests.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import FastPaymentsSettings
import XCTest

final class MicroServices_ContractUpdaterTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getContractSpy, updateContractSpy) = makeSUT()
        
        XCTAssertEqual(getContractSpy.callCount, 0)
        XCTAssertEqual(updateContractSpy.callCount, 0)
    }
    
    func test_process_shouldNotCallGetContractOn_updateContractConnectivityErrorFailure() {
        
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        sut.process(makePayload(.active)) { _ in }
        updateContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertEqual(getContractSpy.callCount, 0)
    }
    
    func test_process_shouldNotCallGetContractOn_updateContractServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        sut.process(makePayload(.active)) { _ in }
        updateContractSpy.complete(with: .failure(.serverError(message)))
        
        XCTAssertEqual(getContractSpy.callCount, 0)
    }
    
    func test_process_shouldNotDeliverUpdateContractResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let updateContractSpy: UpdateContractSpy
        (sut, _, updateContractSpy) = makeSUT()
        var expectedResult: SUT.ProcessResult?
        
        sut?.process(makePayload(.active)) { expectedResult = $0 }
        sut = nil
        updateContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNil(expectedResult)
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractConnectivityErrorFailure() {
        
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(.active), toDeliver: .failure(.connectivityError), on: {
            
            updateContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractSuccessWithDifferentActiveStatus() {
        
        let inactive = makeContract(.inactive)
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(.active), toDeliver: .failure(.connectivityError), on: {
            
            updateContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(inactive))
        })
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractSuccessWithDifferentInactiveStatus() {
        
        let active = makeContract(.active)
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(.inactive), toDeliver: .failure(.connectivityError), on: {
            
            updateContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(active))
        })
    }
    
    func test_process_shouldDeliverContractOn_getContractSuccessWithSameActiveStatus() {
        
        let active = makeContract(.active)
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(.active), toDeliver: .success(active), on: {
            
            updateContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(active))
        })
    }
    
    func test_process_shouldDeliverContractOn_getContractSuccessWithSameInactiveStatus() {
        
        let inactive = makeContract(.inactive)
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(.inactive), toDeliver: .success(inactive), on: {
            
            updateContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(inactive))
        })
    }
    
    func test_process_shouldDeliverServerErrorOn_getContractServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(.active), toDeliver: .failure(.serverError(message)), on: {
            
            updateContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_process_shouldDeliverConnectivityErrorOn_getContractSuccessNil() {
        
        let (sut, getContractSpy, updateContractSpy) = makeSUT()
        
        expect(sut, with: makePayload(.active), toDeliver: .failure(.connectivityError), on: {
            
            updateContractSpy.complete(with: .success(()))
            getContractSpy.complete(with: .success(nil))
        })
    }
    
    func test_process_shouldDeliverGetContractResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getContractSpy: GetContractSpy
        let updateContractSpy: UpdateContractSpy
        (sut, getContractSpy, updateContractSpy) = makeSUT()
        var expectedResult: SUT.ProcessResult?
        
        sut?.process(makePayload(.active)) { expectedResult = $0 }
        updateContractSpy.complete(with: .success(()))
        sut = nil
        getContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNil(expectedResult)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.ContractUpdater<String, UUID, Contract>
    
    private typealias GetContractSpy = Spy<Void, SUT.GetContractResult>
    private typealias UpdateContractSpy = Spy<SUT.Payload, SUT.UpdateContractResponse>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getContractSpy: GetContractSpy,
        updateContractSpy: UpdateContractSpy
    ) {
        let getContractSpy = GetContractSpy()
        let updateContractSpy = UpdateContractSpy()
        
        let sut = SUT(
            getContract: getContractSpy.process(completion:),
            updateContract: updateContractSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getContractSpy, file: file, line: line)
        trackForMemoryLeaks(updateContractSpy, file: file, line: line)
        
        return (sut, getContractSpy, updateContractSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with payload: SUT.Payload,
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
        
        let id: String
        let status: ContractStatus
    }
    
    private func makePayload(
        contractID: String = UUID().uuidString,
        selectableProductID: SelectableProductID = .account(.init(generateRandom11DigitNumber())),
        _ target: SUT.Payload.TargetStatus
    ) -> SUT.Payload {
        
        .init(
            contractID: contractID,
            selectableProductID: selectableProductID,
            target: target
        )
    }
    
    private func makeContract(
        id: String = anyMessage(),
        _ status: ContractStatus
    ) -> Contract {
        
        .init(id: id, status: status)
    }
}
