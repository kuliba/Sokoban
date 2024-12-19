//
//  RemoteServiceTests.swift
//  
//
//  Created by Igor Malyarov on 01.08.2023.
//

import GenericRemoteService
import XCTest

final class RemoteServiceTests: XCTestCase {
    
    func test_init_shouldNotCallHTTPClient() {
        
        let request = anyRequest()
        let (_, client) = makeSUT(createRequest: { _ in .success(request) })
        
        XCTAssertEqual(client.callCount, 0)
    }
    
    func test_process_shouldDeliverErrorOnMakeRequestError() {
        
        let createRequestError = CreateRequestError("make request error")
        let (sut, _) = makeSUT(createRequest: { _ in .failure(createRequestError) })
        
        assert(sut, delivers: [.failure(.createRequest(createRequestError))])
    }
    
    func test_process_shouldCallHTTPClientWithRequest() {
        
        let request = anyRequest()
        let (sut, client) = makeSUT(createRequest: { _ in .success(request) })
        
        sut.process(()) { _ in }
        
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_process_shouldDeliverPerformRequestErrorOnHTTPClientError() {
        
        let httpError = PerformRequestError("HTTP Error")
        let (sut, client) = makeSUT()
        
        assert(sut, delivers: [
            .failure(.performRequest(.init()))
        ], on: {
            
            client.complete(with: .failure(httpError))
        })
    }
    
    func test_process_shouldNotDeliverHTTPClientResultOnSUTInstanceDeallocation() {
        
        let client = Spy()
        var sut: SUT? = .init(
            createRequest: { _ in .success(anyRequest()) },
            performRequest: client.get(_:completion:),
            mapResponse: { _,_ in .failure(.init()) }
        )
        
        var result: SUT.ProcessResult?
        sut?.process(()) {
            result = $0
        }
        sut = nil
        client.complete(with: .failure(.init()))
        
        XCTAssertNil(result)
    }
    
    func test_process_shouldDeliverMapResponseErrorOnMapResponseError() {
        
        let mapResponseError = MapResponseError("important!")
        let (sut, client) = makeSUT(mapResponse: { _,_ in .failure(mapResponseError) })
        
        assert(sut, delivers: [
            .failure(.mapResponse(mapResponseError))
        ], on: {
            
            client.complete(with: .success(successResponse()))
        })
    }
    
    func test_process_shouldDeliverValueOnSuccess() {
        
        let output = Output()
        let (sut, client) = makeSUT(mapResponse: { _,_ in .success(output) })
        
        assert(sut, delivers: [.success(output)], on: {
            
            client.complete(with: .success(successResponse()))
        })
    }
    
    // MARK: - Helpers
    
    private typealias Input = Void
    private typealias SUT = RemoteService<Input, Output, CreateRequestError, PerformRequestError, MapResponseError>
    private typealias Spy = HTTPClientSpy<(Data, HTTPURLResponse)>
    
    private func makeSUT(
        createRequest: SUT.CreateRequest? = nil,
        mapResponse: SUT.MapResponse? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        client: Spy
    ) {
        let createRequest = createRequest ?? { _ in .success(anyRequest()) }
        let mapResponse = mapResponse ?? { _ in .success(.init()) }
        let client = Spy()
        let sut = SUT(
            createRequest: createRequest,
            performRequest: client.get(_:completion:),
            mapResponse: mapResponse
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func assert(
        _ sut: SUT,
        with input: Input = (),
        delivers expectedResults: [SUT.ProcessResult],
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [SUT.ProcessResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.process(input) {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        waitForExpectations(timeout: 1.0)
        
        assert(receivedResults, equalsTo: expectedResults, file: file, line: line)
    }
}
