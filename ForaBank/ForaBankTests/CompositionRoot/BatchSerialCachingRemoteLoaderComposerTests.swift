//
//  BatchSerialCachingRemoteLoaderComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 15.09.2024.
//

import ForaTools
import Foundation
import RemoteServices

extension RemoteDomain {
    
    /// Performs batch network requests with an array of payloads.
    ///
    /// - Parameters:
    ///   - payloads: An array of payloads to process.
    ///   - completion: A closure called with the array of payloads that failed during processing.
    typealias BatchService = ([Payload], @escaping ([Payload]) -> Void) -> Void
}

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
    
    private let updateMaker: UpdateMaker
    private let nanoServiceFactory: RemoteNanoServiceFactory
    
    init(
        updateMaker: UpdateMaker,
        nanoServiceFactory: RemoteNanoServiceFactory
    ) {
        self.updateMaker = updateMaker
        self.nanoServiceFactory = nanoServiceFactory
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
        let batcher = Batcher(perform: decorator.decorated(_:completion:))
        
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
    
    convenience init<T>(
        perform: @escaping (Parameter, @escaping (Result<T, Error>) -> Void) -> Void
    ) {
        self.init(perform: { parameter, completion in
            
            perform(parameter) {
                
                switch $0 {
                case let .failure(failure):
                    completion(failure)
                    
                case .success:
                    completion(nil)
                }
            }
        })
    }
}

@testable import ForaBank
import XCTest

final class BatchSerialCachingRemoteLoaderComposerTests: XCTestCase {
    
}

// MARK: - API check

private extension BatchSerialCachingRemoteLoaderComposer {
    
    convenience init() {
        
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
            updateMaker: localLoaderComposer,
            nanoServiceFactory: nanoServiceComposer
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
