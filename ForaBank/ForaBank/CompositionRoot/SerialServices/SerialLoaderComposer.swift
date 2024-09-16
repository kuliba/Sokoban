//
//  SerialLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.09.2024.
//

import ForaTools
import Foundation
import RemoteServices

/// A composer responsible for creating loaders that handle serial-stamped data, supporting both local and remote data sources with caching capabilities.
final class SerialLoaderComposer {
    
    private let localComposer: LocalLoaderComposer
    private let nanoServiceComposer: LoggingRemoteNanoServiceComposer
    
    /// Initialises a new instance of `SerialLoaderComposer`.
    ///
    /// - Parameters:
    ///   - localComposer: Composer for local data loading and saving.
    ///   - nanoServiceComposer: Composer for remote data loading with logging capabilities.
    init(
        localComposer: LocalLoaderComposer,
        nanoServiceComposer: LoggingRemoteNanoServiceComposer
    ) {
        self.localComposer = localComposer
        self.nanoServiceComposer = nanoServiceComposer
    }
}

extension SerialLoaderComposer {
    
    typealias Serial = String
    typealias Load<T> = (@escaping (T?) -> Void) -> Void
    
    /// Composes loaders for serial-stamped data with caching, supporting both local and remote data sources.
    ///
    /// - Warning: Use for atomic services only, don't use for `dict/getOperatorsListByParam` which performs a sequence of requests and should use `composeUpdate` instead of `composeSave` to cache data.
    ///
    /// - Parameters:
    ///   - getSerial: A closure that retrieves the current serial value.
    ///   - fromModel: A closure that transforms an array of `Model` into an array of `T`.
    ///   - toModel: A closure that transforms an array of `T` back into an array of `Model`.
    ///   - createRequest: A closure that creates a `URLRequest` using an optional `Serial`. Can throw an error.
    ///   - mapResponse: A closure that maps the response data and HTTP response into a `MappingResult` containing `SerialStamped` data.
    ///
    /// - Returns: A tuple containing the local and remote loaders.
    func compose<T, Model: Codable>(
        getSerial: @escaping () -> Serial?,
        fromModel: @escaping ([Model]) -> [T],
        toModel: @escaping ([T]) -> [Model],
        createRequest: @escaping (Serial?) throws -> URLRequest,
        mapResponse: @escaping (Data, HTTPURLResponse) -> RemoteServices.ResponseMapper.MappingResult<RemoteServices.SerialStamped<String, T>>
    ) -> (local: Load<[T]>, remote: Load<[T]>) {
        
        let localLoad = localComposer.composeLoad(fromModel: fromModel)
        
        let save = localComposer.composeSave(toModel: toModel)
        
        let remoteLoad = nanoServiceComposer.compose(
            createRequest: createRequest,
            mapResponse: mapResponse
        )
        
        let decorator = SerialStampedCachingDecorator(
            decoratee: remoteLoad,
            save: save
        )
        
        let fallback = SerialFallback<Serial, T, Error>(
            getSerial: getSerial,
            primary: decorator.decorated,
            secondary: localLoad
        )
        
        return (localLoad, fallback.callAsFunction(completion:))
    }
}

private extension SerialStampedCachingDecorator where Payload == Serial? {
    
    /// A completion handler type for the remote decoratee function.
    ///
    /// - Parameter result: A `Result` containing either a `RemoteServices.SerialStamped<Serial, T>` on success or an `Error` on failure.
    typealias RemoteDecorateeCompletion<T> = (Result<RemoteServices.SerialStamped<Serial, T>, Error>) -> Void
    
    /// A remote decoratee function that fetches data.
    ///
    /// - Parameters:
    ///   - serial: An optional `Serial` used to fetch the remote data.
    ///   - completion: A closure that handles the result of the remote fetch.
    typealias RemoteDecoratee<T> = (Serial?, @escaping RemoteDecorateeCompletion<T>) -> Void
    
    /// A function type for saving data locally.
    ///
    /// - Parameters:
    ///   - items: An array of items of type `T` to be saved.
    ///   - serial: The `Serial` associated with the items.
    ///   - completion: A closure that handles the result of the save operation.
    typealias Save<T> = ([T], Serial, @escaping CacheCompletion) -> Void
    
    /// Convenience initialiser for `SerialStampedCachingDecorator` when the `Value` is an array of `T`.
    ///
    /// This initialiser sets up the decorator to handle multiple items by transforming the remote response
    /// into the expected format and handling the saving of multiple items locally.
    ///
    /// - Parameters:
    ///   - decoratee: The remote loader function that fetches data.
    ///   - save: The function responsible for saving data locally.
    convenience init<T>(
        decoratee: @escaping RemoteDecoratee<T>,
        save: @escaping Save<T>
    ) where Value == [T] {
        
        self.init(
            decoratee: { serial, completion in
                
                decoratee(serial) { result in
                    
                    completion(result.map {
                        
                        return .init(value: $0.list, serial: $0.serial)
                    })
                }
            },
            cache: { payload, completion in
                
                save(payload.value, payload.serial, completion)
            }
        )
    }
}
