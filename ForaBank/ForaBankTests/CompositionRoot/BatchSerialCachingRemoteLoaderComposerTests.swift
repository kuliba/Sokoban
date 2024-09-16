//
//  BatchSerialCachingRemoteLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 15.09.2024.
//

import ForaTools
import Foundation
import RemoteServices

protocol UpdateMaker {
    
    typealias ToModel<T, Model> = (T) -> Model
    typealias Reduce<Model> = (Model, Model) -> (Model, Bool)
    typealias Update<T> = (T, String?, @escaping (Result<Void, Error>) -> Void) -> Void
    
    func makeUpdate<T, Model: Codable>(
        toModel: @escaping ToModel<T, Model>,
        reduce: @escaping Reduce<Model>
    ) -> Update<T>
}

final class BatchSerialCachingRemoteLoaderComposer {
    
    private let nanoServiceFactory: RemoteNanoServiceFactory
    private let updateMaker: UpdateMaker
    
    init(
        nanoServiceFactory: RemoteNanoServiceFactory,
        updateMaker: UpdateMaker
    ) {
        self.nanoServiceFactory = nanoServiceFactory
        self.updateMaker = updateMaker
    }
}

extension BatchSerialCachingRemoteLoaderComposer {
    
    func compose<Payload, T, Model: Codable & Identifiable>(
        getSerial: @escaping (Payload) -> String?,
        makeRequest: @escaping StringSerialRemoteDomain<Payload, T>.MakeRequest,
        mapResponse: @escaping StringSerialRemoteDomain<Payload, T>.MapResponse,
        toModel: @escaping ([T]) -> [Model]
    ) -> StringSerialRemoteDomain<Payload, T>.BatchService {
        
        let perform = nanoServiceFactory.compose(
            makeRequest: makeRequest,
            mapResponse: mapResponse
        )
        let update = updateMaker.makeUpdate(
            toModel: toModel,
            reduce: { $0.updated(with: $1) }
        )
        let decorator = SerialStampedCachingDecorator(
            decoratee: perform,
            getSerial: getSerial,
            save: update
        )
        let batcher = Batcher(perform: decorator.decorated)
        
        return batcher.callAsFunction
    }
}

// MARK: - Adapters

private extension SerialStampedCachingDecorator {
    
    typealias _RemoteDecorateeCompletion<T> = (Result<RemoteServices.SerialStamped<Serial, T>, Error>) -> Void
    
    typealias _RemoteDecoratee<T> = (Payload, @escaping _RemoteDecorateeCompletion<T>) -> Void
    
    typealias _Save<T> = ([T], Serial, @escaping CacheCompletion) -> Void
    
    convenience init<T>(
        decoratee: @escaping _RemoteDecoratee<T>,
        getSerial: @escaping (Payload) -> Serial?,
        save: @escaping _Save<T>
    ) where Value == [T] {
        
        self.init(
            decoratee: { withSerial, completion in
                
                decoratee(withSerial) { completion($0.map(\.stamped)) }
            },
            getSerial: getSerial,
            cache: { save($0.value, $0.serial, $1) }
        )
    }
}

private extension RemoteServices.SerialStamped {
    
    var stamped: ForaTools.SerialStamped<Serial, [T]> {
        
        return .init(value: list, serial: serial)
    }
}

private extension Batcher {
    
    typealias ResultPerform<T> = (Parameter, @escaping (Result<T, Error>) -> Void) -> Void
    
    convenience init<T>(
        perform: @escaping ResultPerform<T>
    ) {
        self.init(perform: { parameter, completion in
            
            perform(parameter) {
                
                guard case let .failure(failure) = $0
                else { return completion(nil) }
                
                completion(failure)
            }
        })
    }
}

@testable import ForaBank
import XCTest

final class BatchSerialCachingRemoteLoaderComposerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, httpClientSpy, updateMakerSpy) = makeSUT()
        
        XCTAssertEqual(httpClientSpy.callCount, 0)
        XCTAssertEqual(updateMakerSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = BatchSerialCachingRemoteLoaderComposer
    private typealias Domain = StringSerialRemoteDomain<Payload, Value>
    private typealias SUT = Domain.BatchService
    private typealias MakeRequestSpy = CallSpy<Payload, URLRequest>
    private typealias StampedResult = Result<RemoteServices.SerialStamped<String, Value>, RemoteServices.ResponseMapper.MappingError>
    private typealias MapResponseSpy = CallSpy<(Data, HTTPURLResponse), StampedResult>
    private typealias ToModelSpy = CallSpy<[Value], [Model]>
    
    private func makeSUT(
        serial: String? = nil,
        makeRequestStub: URLRequest? = nil,
        mapResponseStub: StampedResult? = nil,
        models: [Model] = [],
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
        let makeRequestSpy = MakeRequestSpy(
            stubs: [makeRequestStub ?? anyURLRequest()]
        )
        let mapResponseStub = mapResponseStub ?? .failure(.invalid(statusCode: 200, data: .empty))
        let mapResponseSpy = MapResponseSpy(
            stubs: [mapResponseStub]
        )
        let toModelSpy = ToModelSpy(stubs: [models])
        let sut = composer.compose(
            getSerial: { _ in serial },
            makeRequest: makeRequestSpy.call(payload:),
            mapResponse: mapResponseSpy.call(_:_:),
            toModel: toModelSpy.call(payload:)
        )
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(httpClientSpy, file: file, line: line)
        trackForMemoryLeaks(makeRequestSpy, file: file, line: line)
        trackForMemoryLeaks(mapResponseSpy, file: file, line: line)
        trackForMemoryLeaks(toModelSpy, file: file, line: line)
        trackForMemoryLeaks(updateMakerSpy, file: file, line: line)
        
        return (sut, httpClientSpy, updateMakerSpy)
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
    
    private func makePayload(
        _ value: String = anyMessage()
    ) -> Payload {
        
        return .init(value: value)
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}

final class UpdateMakerSpy: UpdateMaker {
    
    private(set) var messages = [Message]()
    
    var callCount: Int { messages.count }
    
    func makeUpdate<T, Model>(
        toModel: @escaping ToModel<T, Model>,
        reduce: @escaping Reduce<Model>
    ) -> Update<T> where Model: Codable {
        
        return { value, serial, completion in
        
            self.messages.append(.init(value: value, serial: serial, completion: completion))
        }
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

private extension BatchSerialCachingRemoteLoaderComposer {
    
    convenience init(apiCheckOnly: Bool) {
        
        let model: Model = .shared
        let agent = model.localAgent
        let localLoaderComposer = LocalLoaderComposer(
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
            updateMaker: localLoaderComposer
        )
    }
}

extension LocalLoaderComposer: UpdateMaker {
    
    func makeUpdate<T, Model: Codable>(
        toModel: @escaping ToModel<T, Model>,
        reduce: @escaping Reduce<Model>
    ) -> Update<T> {
        
        composeUpdate(toModel: toModel, reduce: reduce)
    }
}
