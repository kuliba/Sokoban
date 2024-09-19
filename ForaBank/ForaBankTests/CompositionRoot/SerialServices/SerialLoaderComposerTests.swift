//
//  SerialLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 12.09.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class SerialLoaderComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, agent, httpClient) = makeSUT()
        
        XCTAssertEqual(agent.loadCallCount, 0)
        XCTAssertEqual(agent.storeCallCount, 0)
        XCTAssertEqual(httpClient.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - local
    
    func test_local_shouldCallLocalAgent() {
        
        let (sut, agent, _) = makeSUT()
        let (local, _) = compose(sut)
        let exp = expectation(description: "wait for local load completion")
        
        local { _ in exp.fulfill() }
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(agent.loadCallCount, 1)
    }
    
    func test_local_shouldNotCallHTTPClient() {
        
        let (sut, _, httpClient) = makeSUT()
        let (local, _) = compose(sut)
        let exp = expectation(description: "wait for local load completion")
        
        local { _ in exp.fulfill() }
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(httpClient.callCount, 0)
    }

    // MARK: - remote
    
    func test_remote_shouldCallHTTPClient() {
        
        let (sut, _, httpClient) = makeSUT()
        let (_, remote) = compose(sut)
        let exp = expectation(description: "wait for remote load completion")
        
        remote { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(httpClient.callCount, 1)
    }
    
    func test_remote_shouldNotCallLocalAgentOnFailure() {
        
        let (sut, agent, httpClient) = makeSUT()
        let (_, remote) = compose(sut)
        let exp = expectation(description: "wait for remote load completion")
        
        remote { _ in exp.fulfill() }
        httpClient.complete(with: .failure(anyError()))
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(agent.storeCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SerialLoaderComposer
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
        let asyncLocalAgent = LocalAgentAsyncWrapper(
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
        
        let sut = SUT(
            asyncLocalAgent: asyncLocalAgent,
            nanoServiceComposer: nanoServiceComposer
        )
        
        trackForMemoryLeaks(agent, file: file, line: line)
        // trackForMemoryLeaks(interactiveScheduler, file: file, line: line)
        // trackForMemoryLeaks(backgroundScheduler, file: file, line: line)
        trackForMemoryLeaks(asyncLocalAgent, file: file, line: line)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(logger, file: file, line: line)
        trackForMemoryLeaks(nanoServiceComposer, file: file, line: line)
        
        return (sut, agent, httpClient)
    }
    
    private func compose(
        _ sut: SUT,
        with serial: SUT.Serial? = nil
    ) -> (local: SUT.Load<[ServiceCategory]>, remote: SUT.Load<[ServiceCategory]>) {
        
        sut.compose(
            getSerial: { serial },
            fromModel: [ServiceCategory].init(codable:),
            toModel: [CodableServiceCategory].init(categories:),
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetServiceCategoryListResponse
        )
    }
}
