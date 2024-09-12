//
//  RootViewModelFactory+makeLoadServiceCategoriesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.09.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_makeLoadServiceCategoriesTests: XCTestCase {
    
    // MARK: - make
    
    func test_make_shouldNotCallCollaborators() {
        
        let (sut, agent, httpClient) = makeSUT()
        
        XCTAssertEqual(agent.loadCallCount, 0)
        XCTAssertEqual(agent.storeCallCount, 0)
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - local
    
    func test_local_shouldCallLocalAgent() {
        
        let (sut, agent, _) = makeSUT()
        let exp = expectation(description: "wait for local load completion")
        
        sut.local { _ in exp.fulfill() }
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(agent.loadCallCount, 1)
    }
    
    func test_local_shouldNotCallHTTPClient() {
        
        let (sut, _, httpClient) = makeSUT()
        let exp = expectation(description: "wait for local load completion")
        
        sut.local { _ in exp.fulfill() }
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(httpClient.callCount, 0)
    }
    
    // MARK: - remote
    
    func test_remote_shouldCallHTTPClient() {
        
        let (sut, _, httpClient) = makeSUT()
        let exp = expectation(description: "wait for remote load completion")
        
        sut.remote { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(httpClient.callCount, 1)
    }
    
    func test_remote_shouldNotCallLocalAgentOnFailure() {
        
        let (sut, agent, httpClient) = makeSUT()
        let exp = expectation(description: "wait for remote load completion")
        
        sut.remote { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(agent.storeCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias Load = RootViewModelFactory._LoadServiceCategories
    private typealias SUT = (local: Load, remote: Load)
    private typealias LocalAgent = LocalAgentSpy<[CodableServiceCategory]>
    
    private func makeSUT(
        loadStub: [CodableServiceCategory]? = nil,
        storeStub: Result<Void, any Error> = .failure(anyError()),
        serialStub: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        agent: LocalAgent,
        // interactiveScheduler: TestSchedulerOf<DispatchQueue>,
        // backgroundScheduler: TestSchedulerOf<DispatchQueue>
        httpClient: HTTPClientSpy
        // logger: LoggerAgent
    ) {
        
        let agent = LocalAgent(
            loadStub: loadStub,
            storeStub: storeStub,
            serialStub: serialStub
        )
        // let interactiveScheduler = DispatchQueue.test
        // let backgroundScheduler = DispatchQueue.test
        let localComposer = LocalLoaderComposer(
            agent: agent,
            // interactiveScheduler: interactiveScheduler.eraseToAnyScheduler(),
            interactiveScheduler: .immediate,
            // backgroundScheduler: backgroundScheduler.eraseToAnyScheduler()
            backgroundScheduler: .immediate
        )
        let httpClient = HTTPClientSpy()
        let logger = LoggerAgent()
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClient,
            logger: logger
        )
        
        let sut = RootViewModelFactory.makeLoadServiceCategories(
            getSerial: { serialStub },
            localComposer: localComposer,
            nanoServiceComposer: nanoServiceComposer
        )
        
        trackForMemoryLeaks(agent, file: file, line: line)
        // trackForMemoryLeaks(interactiveScheduler, file: file, line: line)
        // trackForMemoryLeaks(backgroundScheduler, file: file, line: line)
        trackForMemoryLeaks(localComposer, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        trackForMemoryLeaks(nanoServiceComposer, file: file, line: line)
        
        return (sut, agent, httpClient)
    }
}
