//
//  SerialCachingRemoteBatchServiceComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.09.2024.
//

import ForaTools
import Foundation
import RemoteServices

/// A composer for creating batch services with serial caching remote loaders.
final class SerialCachingRemoteBatchServiceComposer {
    
    /// Factory for creating remote nano services.
    private let nanoServiceFactory: RemoteNanoServiceFactory
    
    /// Maker for creating update functions.
    private let updateMaker: UpdateMaker
    
    /// Initialises the composer with the given nano service factory and update maker.
    ///
    /// - Parameters:
    ///   - nanoServiceFactory: Factory to create remote nano services.
    ///   - updateMaker: Maker to create update functions for caching.
    init(
        nanoServiceFactory: RemoteNanoServiceFactory,
        updateMaker: UpdateMaker
    ) {
        self.nanoServiceFactory = nanoServiceFactory
        self.updateMaker = updateMaker
    }
}

/// Protocol defining a maker for creating update functions.
protocol UpdateMaker {
    
    /// Function that transforms a value of type `T` to `Model`.
    typealias ToModel<T, Model> = (T) -> Model
    
    /// Function that reduces two `Model` instances into one, indicating if a change occurred.
    typealias Reduce<Model> = (Model, Model) -> (Model, Bool)
    
    /// Update function that processes a value of type `T`, an optional serial, and a completion handler.
    typealias Update<T> = (T, String?, @escaping (Result<Void, Error>) -> Void) -> Void
    
    /// Creates an update function for caching.
    ///
    /// - Parameters:
    ///   - toModel: Function to transform `T` into `Model`.
    ///   - reduce: Function to combine two `Model` instances into one.
    /// - Returns: An update function of type `Update<T>`.
    func makeUpdate<T, Model: Codable>(
        toModel: @escaping ToModel<T, Model>,
        reduce: @escaping Reduce<Model>
    ) -> Update<T>
}

extension SerialCachingRemoteBatchServiceComposer {
    
    /// Composes a batch service with serial caching capabilities.
    ///
    /// - Parameters:
    ///   - getSerial: Function to retrieve the serial string from a `Payload`.
    ///   - makeRequest: Function to create a network request from a `Payload`.
    ///   - mapResponse: Function to map a network response to the expected type.
    ///   - toModel: Function to transform an array of `[T]` into `[Model]`.
    /// - Returns: A batch service that performs the composed operations.
    func compose<Payload, T, Model: Codable & Identifiable>(
        getSerial: @escaping (Payload) -> String?,
        makeRequest: @escaping StringSerialRemoteDomain<Payload, T>.MakeRequest,
        mapResponse: @escaping StringSerialRemoteDomain<Payload, T>.MapResponse,
        toModel: @escaping ([T]) -> [Model]
    ) -> BatchService<Payload> {
        
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
        
        return batcher.process
    }
}

// MARK: - Adapters

private extension SerialStampedCachingDecorator {
    
    /// Completion handler type for the remote decoratee.
    typealias _RemoteDecorateeCompletion<T> = (Result<RemoteServices.SerialStamped<Serial, T>, Error>) -> Void
    
    /// Type for the remote decoratee function.
    typealias _RemoteDecoratee<T> = (Payload, @escaping _RemoteDecorateeCompletion<T>) -> Void
    
    /// Type for the save function used in caching.
    typealias _Save<T> = ([T], Serial, @escaping CacheCompletion) -> Void
    
    /// Convenience initialiser for `SerialStampedCachingDecorator` when `Value` is `[T]`.
    ///
    /// - Parameters:
    ///   - decoratee: The remote decoratee function.
    ///   - getSerial: Function to get the serial from `Payload`.
    ///   - save: Function to save the cached data.
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
    
    /// Perform function type that returns a result.
    typealias ResultPerform<T> = (Parameter, @escaping (Result<T, Error>) -> Void) -> Void
    
    /// Convenience initialiser for `Batcher` when using a perform function that returns a result.
    ///
    /// - Parameter perform: The perform function that returns a result.
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
