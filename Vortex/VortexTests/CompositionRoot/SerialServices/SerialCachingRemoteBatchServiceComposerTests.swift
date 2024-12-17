//
//  SerialCachingRemoteBatchServiceComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 15.09.2024.
//

@testable import ForaBank
import RemoteServices
import XCTest

final class SerialCachingRemoteBatchServiceComposerTests: XCTestCase {
    
    // MARK: - compose
    
    func test_compose_shouldNotCallCollaborators() {
        
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT()
        
        XCTAssertEqual(httpClientSpy.callCount, 0)
        XCTAssertEqual(updateMakerSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - call: empty payloads
    
    func test_shouldDeliverEmptyOnEmptyPayloads() {
        
        let (sut, _,_) = makeSUT()
        
        expect(sut, with: [], toDeliver: []) {}
    }
    
    func test_shouldNotCallHTTPClientOnEmptyPayloads() {
        
        let (sut, httpClientSpy, _) = makeSUT()
        
        expect(sut, with: [], toDeliver: []) {
            
            XCTAssertEqual(httpClientSpy.callCount, 0)
        }
    }
    
    func test_shouldNotCallUpdateOnEmptyPayloads() {
        
        let (sut, _, updateMakerSpy) = makeSUT()
        
        expect(sut, with: [], toDeliver: []) {
            
            XCTAssertEqual(updateMakerSpy.callCount, 0)
        }
    }
    
    // MARK: - call: one payload
    
    func test_shouldCallHTTPClientWithRequest() {
        
        let request = anyURLRequest()
        let (sut, httpClientSpy, _) = makeSUT(makeRequestStub: [request])
        
        sut([makePayload()]) { _ in }
        
        XCTAssertNoDiff(httpClientSpy.requests, [request])
    }
    
    func test_shouldDeliverPayloadOnHTTPClientFailure() {
        
        let payload = makePayload()
        let (sut, httpClientSpy, _) = makeSUT()
        
        expect(sut, with: [payload], toDeliver: [payload]) {
            
            httpClientSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_shouldNotCallUpdateOnHTTPClientFailure() {
        
        let payload = makePayload()
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT()
        
        expect(sut, with: [payload], toDeliver: [payload]) {
            
            httpClientSpy.complete(with: .failure(anyError()))
            XCTAssertEqual(updateMakerSpy.callCount, 0)
        }
    }
    
    func test_shouldDeliverEmptyOnUpdateFailure() {
        
        let payload = makePayload()
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            mapResponseStub: [mapResponseSuccess()]
        )
        
        expect(sut, with: [payload], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_shouldDeliverEmptyOnUpdateSuccess() {
        
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            mapResponseStub: [mapResponseSuccess()]
        )
        
        expect(sut, with: [makePayload()], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .success(()))
        }
    }
    
    func test_shouldCallUpdateOnSuccessWithEmptyList() {
        
        let serial = anyMessage()
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            mapResponseStub: [mapResponseSuccess(list: [], serial: serial)]
        )
        
        expect(sut, with: [makePayload()], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .success(()))
            
            XCTAssertEqual(updateMakerSpy.values(), [[Value]()])
            XCTAssertEqual(updateMakerSpy.serials, [serial])
        }
    }
    
    func test_shouldCallUpdateOnSuccess() {
        
        let (value, serial) = (makeValue(), anyMessage())
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            mapResponseStub: [mapResponseSuccess(list: [value], serial: serial)]
        )
        
        expect(sut, with: [makePayload()], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .success(()))
            
            XCTAssertEqual(updateMakerSpy.values(), [[value]])
            XCTAssertEqual(updateMakerSpy.serials, [serial])
        }
    }
    
    // MARK: - call: two payloads
    
    func test_shouldCallHTTPClientWithRequests() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let (request1, request2) = (anyURLRequest(), anyURLRequest())
        let (sut, httpClientSpy, _) = makeSUT(
            makeRequestStub: [request1, request2]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: [payload1, payload2]) {
            
            httpClientSpy.complete(with: .failure(anyError()))
            httpClientSpy.complete(with: .failure(anyError()), at: 1)
            
            XCTAssertNoDiff(httpClientSpy.requests, [request1, request2])
        }
    }
    
    func test_shouldDeliverPayloadsOnHTTPClientFailures() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let (sut, httpClientSpy, _) = makeSUT(
            makeRequestStub: [anyURLRequest(), anyURLRequest()],
            mapResponseStub: [makeStampedFailure(), makeStampedFailure()]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: [payload1, payload2]) {
            
            httpClientSpy.complete(with: .failure(anyError()))
            httpClientSpy.complete(with: .failure(anyError()), at: 1)
        }
    }
    
    func test_shouldNotCallUpdateOnHTTPClientFailures() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            makeRequestStub: [anyURLRequest(), anyURLRequest()],
            mapResponseStub: [makeStampedFailure(), makeStampedFailure()]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: [payload1, payload2]) {
            
            httpClientSpy.complete(with: .failure(anyError()))
            httpClientSpy.complete(with: .failure(anyError()), at: 1)
            XCTAssertEqual(updateMakerSpy.callCount, 0)
        }
    }
    
    func test_shouldDeliverEmptyOnUpdateFailureWithTwoPayloads() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            makeRequestStub: [anyURLRequest(), anyURLRequest()],
            mapResponseStub: [mapResponseSuccess(), mapResponseSuccess()]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .failure(anyError()))
            
            httpClientSpy.complete(with: httpClientSuccess(), at: 1)
            updateMakerSpy.complete(with: .failure(anyError()), at: 1)
        }
    }
    
    func test_shouldDeliverEmptyOnUpdateSuccessWithTwoPayloads() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            makeRequestStub: [anyURLRequest(), anyURLRequest()],
            mapResponseStub: [mapResponseSuccess(), mapResponseSuccess()]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .success(()))
            
            httpClientSpy.complete(with: httpClientSuccess(), at: 1)
            updateMakerSpy.complete(with: .success(()), at: 1)
        }
    }
    
    func test_shouldDeliverEmptyOnUpdateMixWithTwoPayloads() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            makeRequestStub: [anyURLRequest(), anyURLRequest()],
            mapResponseStub: [mapResponseSuccess(), mapResponseSuccess()]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .failure(anyError()))

            httpClientSpy.complete(with: httpClientSuccess(), at: 1)
            updateMakerSpy.complete(with: .success(()), at: 1)
        }
    }
    
    func test_shouldCallUpdateOnSuccessWithTwoPayloadsOneEmptyList() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let serial1 = anyMessage()
        let (value2, serial2) = (makeValue(), anyMessage())
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            makeRequestStub: [anyURLRequest(), anyURLRequest()],
            mapResponseStub: [
                mapResponseSuccess(list: [], serial: serial1),
                mapResponseSuccess(list: [value2], serial: serial2),
            ]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .success(()))
            
            httpClientSpy.complete(with: httpClientSuccess(), at: 1)
            updateMakerSpy.complete(with: .success(()), at: 1)

            XCTAssertEqual(updateMakerSpy.values(), [[], [value2]])
            XCTAssertEqual(updateMakerSpy.serials, [serial1, serial2])
        }
    }
    
    func test_shouldCallUpdateOnSuccessWithTwoPayloads() {
        
        let (payload1, payload2) = (makePayload(), makePayload())
        let (value1, serial1) = (makeValue(), anyMessage())
        let (value2, serial2) = (makeValue(), anyMessage())
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT(
            makeRequestStub: [anyURLRequest(), anyURLRequest()],
            mapResponseStub: [
                mapResponseSuccess(list: [value1], serial: serial1),
                mapResponseSuccess(list: [value2], serial: serial2),
            ]
        )
        
        expect(sut, with: [payload1, payload2], toDeliver: []) {
            
            httpClientSpy.complete(with: httpClientSuccess())
            updateMakerSpy.complete(with: .success(()))
            
            httpClientSpy.complete(with: httpClientSuccess(), at: 1)
            updateMakerSpy.complete(with: .success(()), at: 1)

            XCTAssertEqual(updateMakerSpy.values(), [[value1], [value2]])
            XCTAssertEqual(updateMakerSpy.serials, [serial1, serial2])
        }
    }
    
    // MARK: - Helpers
    
    private typealias Composer = SerialCachingRemoteBatchServiceComposer
    private typealias Domain = StringSerialRemoteDomain<Payload, Value>
    private typealias SUT = BatchService<Payload>
    private typealias MakeRequestSpy = CallSpy<Payload, URLRequest>
    private typealias StampedResult = Result<RemoteServices.SerialStamped<String, Value>, RemoteServices.ResponseMapper.MappingError>
    private typealias MapResponseSpy = CallSpy<(Data, HTTPURLResponse), StampedResult>
    private typealias ToModelSpy = CallSpy<[Value], [Model]>
    
    private func makeSUT(
        makeRequestStub: [URLRequest] = [anyURLRequest()],
        mapResponseStub: [StampedResult] = [.failure(.invalid(statusCode: 200, data: .empty))],
        toModels models: [Model] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClientSpy: HTTPClientSpy,
        updateMakerSpy: UpdateMakerSpy
    ) {
        let httpClientSpy = HTTPClientSpy()
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: httpClientSpy,
            // TODO: add logging tests
            logger: LoggerAgent()
        )
        let updateMakerSpy = UpdateMakerSpy()
        let composer = Composer(
            nanoServiceFactory: nanoServiceComposer,
            updateMaker: updateMakerSpy
        )
        let makeRequestSpy = MakeRequestSpy(stubs: makeRequestStub)
        let mapResponseSpy = MapResponseSpy(stubs: mapResponseStub)
        let toModelSpy = ToModelSpy(stubs: [models])
        let sut = composer.compose(
            makeRequest: makeRequestSpy.call(payload:),
            mapResponse: mapResponseSpy.call(_:_:),
            toModel: toModelSpy.call(payload:)
        )
        
        // TODO: fix and restore memory leaks tracking
        trackForMemoryLeaks(composer, file: file, line: line)
        //    trackForMemoryLeaks(httpClientSpy, file: file, line: line)
        //    trackForMemoryLeaks(makeRequestSpy, file: file, line: line)
        //    trackForMemoryLeaks(mapResponseSpy, file: file, line: line)
        trackForMemoryLeaks(toModelSpy, file: file, line: line)
        //    trackForMemoryLeaks(updateMakerSpy, file: file, line: line)
        
        return (sut, httpClientSpy, updateMakerSpy)
    }
    
    private func httpClientSuccess(
        _ data: Data = anyData(),
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> HTTPClient.Result {
        
        return .success((data, httpURLResponse))
    }

    private struct Model: Codable, Equatable, Identifiable {
        
        let value: String
        
        var id: String { value }
    }
    
    private func makeModel(
        _ value: String = anyMessage()
    ) -> Model {
        
        return .init(value: value)
    }
    
    private struct Payload: Equatable {
        
        let value: String
    }
    
    private func mapResponseSuccess(
        list: [Value]? = nil,
        serial: String = anyMessage()
    ) -> StampedResult {
        
        return .success(.init(list: list ?? [makeValue()], serial: serial))
    }

    private func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    private func makeStampedFailure(
        _ mappingError: RemoteServices.ResponseMapper.MappingError = .server(statusCode: 200, errorMessage: "Error")
    ) -> StampedResult {
        
        return .failure(mappingError)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
    
    private func expect(
        _ sut: SUT,
        with payloads: [Payload],
        toDeliver expected: [Payload],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut(payloads) { received in
            
            XCTAssertNoDiff(received, expected, "Expected \(expected), got \(received) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}

final class UpdateMakerSpy: UpdateMaker {
    
    private(set) var messages = [Message]()
    
    var callCount: Int { messages.count }
    var serials: [String?] { messages.map(\.serial) }
    
    func makeUpdate<T, Model>(
        toModel: @escaping ToModel<T, Model>,
        reduce: @escaping Reduce<Model>
    ) -> Update<T> where Model: Codable {
        
        return { value, serial, completion in
            
            self.messages.append(.init(
                value: value,
                serial: serial,
                completion: completion
            ))
        }
    }
    
    func complete(
        with result: Result<Void, Error>,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
    
    func values<Value>() -> [Value] {
        
        messages.compactMap { $0.value as? Value }
    }
    
    struct Message {
        
        let value: Any
        let serial: String?
        let completion: (Result<Void, Error>) -> Void
    }
}

// MARK: - API check

private extension SerialCachingRemoteBatchServiceComposer {
    
    convenience init(apiCheckOnly: Bool) {
        
        let model: Model = .shared
        let agent = model.localAgent
        let asyncLocalAgent = LocalAgentAsyncWrapper(
            agent: agent,
            interactiveScheduler: .global(qos: .userInteractive),
            backgroundScheduler: .global(qos: .background)
        )
        let nanoServiceComposer = LoggingRemoteNanoServiceComposer(
            httpClient: model.authenticatedHTTPClient(),
            logger: LoggerAgent()
        )
        
        self.init(
            nanoServiceFactory: nanoServiceComposer,
            updateMaker: asyncLocalAgent
        )
    }
}
