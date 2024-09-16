//
//  BatchSerialCachingRemoteLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.09.2024.
//

import ForaTools
import Foundation
import RemoteServices

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

protocol UpdateMaker {
    
    typealias ToModel<T, Model> = (T) -> Model
    typealias Reduce<Model> = (Model, Model) -> (Model, Bool)
    typealias Update<T> = (T, String?, @escaping (Result<Void, Error>) -> Void) -> Void
    
    func makeUpdate<T, Model: Codable>(
        toModel: @escaping ToModel<T, Model>,
        reduce: @escaping Reduce<Model>
    ) -> Update<T>
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
