//
//  FPSReducerTests.swift
//
//
//  Created by Igor Malyarov on 09.01.2024.
//

final class FPSReducer {
    
    private let getClientConsentMe2MePull: GetClientConsentMe2MePull
    private let getBankDefault: GetBankDefault
    
    init(
        getClientConsentMe2MePull: @escaping GetClientConsentMe2MePull,
        getBankDefault: @escaping GetBankDefault
    ) {
        self.getClientConsentMe2MePull = getClientConsentMe2MePull
        self.getBankDefault = getBankDefault
    }
}

extension FPSReducer {
    
    typealias Completion = (State) -> Void
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping Completion
    ) {
        switch event {
        case .fpsButtonTapped:
            switch state {
            case .tripleYes:
                getClientConsentMe2MePull { [weak self] _ in
                
                    self?.getBankDefault { _ in }
                }
                
            case .tripleNo:
                getClientConsentMe2MePull { [weak self] _ in
                    
                    self?.getBankDefault { _ in }
                }
                
            case .emptyList:
                getClientConsentMe2MePull { _ in }
                
            case .serverError:
                break
                
            case .connectivityError:
                break
            }
        }
    }
}

extension FPSReducer {
    
    typealias GetClientConsentMe2MePullResponse = Void
    typealias GetClientConsentMe2MePullError = Error
    typealias GetClientConsentMe2MePullResult = Result<GetClientConsentMe2MePullResponse, GetClientConsentMe2MePullError>
    typealias GetClientConsentMe2MePullCompletion = (GetClientConsentMe2MePullResult) -> Void
    typealias GetClientConsentMe2MePull = (@escaping GetClientConsentMe2MePullCompletion) -> Void
    
    typealias GetBankDefaultResponse = Void
    typealias GetBankDefaultError = Error
    typealias GetBankDefaultResult = Result<GetBankDefaultResponse, GetBankDefaultError>
    typealias GetBankDefaultCompletion = (GetBankDefaultResult) -> Void
    typealias GetBankDefault = (@escaping GetBankDefaultCompletion) -> Void
}

extension FPSReducer {
    
    enum State: Equatable {
        
        case tripleYes, tripleNo, emptyList, serverError, connectivityError
    }
    
    enum Event: Equatable {
        
        case fpsButtonTapped
    }
}

import XCTest

final class FPSReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getClientConsentMe2MePullSpy, getBankDefaultSpy) = makeSUT()
        
        XCTAssertNoDiff(getClientConsentMe2MePullSpy.callCount, 0)
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 0)
    }
    
    // MARK: - getClientConsentMe2MePull
    
    func test_fpsButtonTapped_shouldCallGetClientConsentMe2MePullOnFastPaymentContractFindListTripleYesResponse_a1() {
        
        let (sut, getClientConsentMe2MePullSpy, _) = makeSUT()
        let tripleYes = tripleYesResponse()
        
        reduce(sut, tripleYes)
        
        XCTAssertNoDiff(getClientConsentMe2MePullSpy.callCount, 1)
    }
    
    func test_fpsButtonTapped_shouldCallGetClientConsentMe2MePullOnFastPaymentContractFindListTripleNoResponse_a2() {
        
        let (sut, getClientConsentMe2MePullSpy, _) = makeSUT()
        let tripleNo = tripleNoResponse()
        
        reduce(sut, tripleNo)
        
        XCTAssertNoDiff(getClientConsentMe2MePullSpy.callCount, 1)
    }
    
    func test_fpsButtonTapped_shouldCallGetClientConsentMe2MePullOnFastPaymentContractFindListEmptyList_a3() {
        
        let (sut, getClientConsentMe2MePullSpy, _) = makeSUT()
        let emptyList = emptyListResponse()
        
        reduce(sut, emptyList)
        
        XCTAssertNoDiff(getClientConsentMe2MePullSpy.callCount, 1)
    }
    
    func test_fpsButtonTapped_shouldNotCallGetClientConsentMe2MePullOnFastPaymentContractFindListServerError_a4() {
        
        let (sut, getClientConsentMe2MePullSpy, _) = makeSUT()
        let serverError = serverError()
        
        reduce(sut, serverError)
        
        XCTAssertNoDiff(getClientConsentMe2MePullSpy.callCount, 0)
    }
    
    func test_fpsButtonTapped_shouldNotCallGetClientConsentMe2MePullOnFastPaymentContractFindListConnectivityError_a5() {
        
        let (sut, getClientConsentMe2MePullSpy, _) = makeSUT()
        let connectivityError = connectivityError()
        
        reduce(sut, connectivityError)
        
        XCTAssertNoDiff(getClientConsentMe2MePullSpy.callCount, 0)
    }
    
    // MARK: - getBankDefault
    
    func test_fpsButtonTapped_shouldCallGetBankDefaultOnGetClientConsentMe2MePullSuccessFastPaymentContractFindListTripleYesResponse_a1() {
        
        let (sut, getClientConsentMe2MePullSpy, getBankDefaultSpy) = makeSUT()
        let tripleYes = tripleYesResponse()
        
        reduce(sut, tripleYes)
        getClientConsentMe2MePullSpy.complete(with: anySuccess())
        
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 1)
    }
    
    func test_fpsButtonTapped_shouldCallGetBankDefaultOnGetClientConsentMe2MePullFailureFastPaymentContractFindListTripleYesResponse_failure_a1() {
        
        let (sut, getClientConsentMe2MePullSpy, getBankDefaultSpy) = makeSUT()
        let tripleYes = tripleYesResponse()
        
        reduce(sut, tripleYes)
        getClientConsentMe2MePullSpy.complete(with: anyFailure())
        
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 1)
    }
    
    func test_fpsButtonTapped_shouldCallGetBankDefaultOnGetClientConsentMe2MePullSuccessFastPaymentContractFindListTripleNoResponse_a2() {
        
        let (sut, getClientConsentMe2MePullSpy, getBankDefaultSpy) = makeSUT()
        let tripleNo = tripleNoResponse()
        
        reduce(sut, tripleNo)
        getClientConsentMe2MePullSpy.complete(with: anySuccess())
        
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 1)
    }
    
    func test_fpsButtonTapped_shouldCallGetBankDefaultOnGetClientConsentMe2MePullFailureFastPaymentContractFindListTripleNoResponse_a2() {
        
        let (sut, getClientConsentMe2MePullSpy, getBankDefaultSpy) = makeSUT()
        let tripleNo = tripleNoResponse()
        
        reduce(sut, tripleNo)
        getClientConsentMe2MePullSpy.complete(with: anyFailure())
        
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 1)
    }
    
    func test_fpsButtonTapped_shouldNotCallGetBankDefaultOnFastPaymentContractFindListEmptyList_a3() {
        
        let (sut, _, getBankDefaultSpy) = makeSUT()
        let emptyList = emptyListResponse()
        
        reduce(sut, emptyList)
        
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 0)
    }
    
    func test_fpsButtonTapped_shouldNotCallGetBankDefaultOnFastPaymentContractFindListServerError_a4() {
        
        let (sut, _, getBankDefaultSpy) = makeSUT()
        let serverError = serverError()
        
        reduce(sut, serverError)
        
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 0)
    }
    
    func test_fpsButtonTapped_shouldNotCallGetBankDefaultOnFastPaymentContractFindListConnectivityError_a5() {
        
        let (sut, _, getBankDefaultSpy) = makeSUT()
        let connectivityError = connectivityError()
        
        reduce(sut, connectivityError)
        
        XCTAssertNoDiff(getBankDefaultSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FPSReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias GetClientConsentMe2MePullSpy = Spy<Void, Void, Error>
    private typealias GetBankDefaultSpy = Spy<Void, Void, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getClientConsentMe2MePullSpy: GetClientConsentMe2MePullSpy,
        getBankDefaultSpy: GetBankDefaultSpy
    ) {
        
        let getClientConsentMe2MePullSpy = GetClientConsentMe2MePullSpy()
        let getBankDefaultSpy = GetBankDefaultSpy()
        let sut = SUT(
            getClientConsentMe2MePull: getClientConsentMe2MePullSpy.process,
            getBankDefault: getBankDefaultSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getClientConsentMe2MePullSpy, file: file, line: line)
        trackForMemoryLeaks(getBankDefaultSpy, file: file, line: line)
        
        return (sut, getClientConsentMe2MePullSpy, getBankDefaultSpy)
    }
    
    private func tripleYesResponse() -> State {
        
        .tripleYes
    }
    
    private func tripleNoResponse() -> State {
        
        .tripleNo
    }
    
    private func emptyListResponse() -> State {
        
        .emptyList
    }
    
    private func serverError() -> State {
        
        .serverError
    }
    
    private func connectivityError() -> State {
        
        .connectivityError
    }
    
    private func reduce(
        _ sut: SUT,
        _ state: State,
        _ completion: @escaping SUT.Completion = { _ in }
    ) {
        sut.reduce(state, .fpsButtonTapped, completion)
    }
}

private func anySuccess(
) -> FPSReducer.GetClientConsentMe2MePullResult {
    
    .success(())
}

private func anyFailure(
) -> FPSReducer.GetClientConsentMe2MePullResult {
    
    .failure(anyError())
}
