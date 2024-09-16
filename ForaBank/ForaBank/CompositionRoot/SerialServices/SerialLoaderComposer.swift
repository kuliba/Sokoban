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

private extension SerialStampedCachingDecorator {
    
    typealias RemoteDecorateeCompletion<T> = (Result<RemoteServices.SerialStamped<Serial, T>, Error>) -> Void
    typealias RemoteDecoratee<T> = (Serial?, @escaping RemoteDecorateeCompletion<T>) -> Void
    typealias Save<T> = ([T], Serial, @escaping CacheCompletion) -> Void
    
    /// Convenience initialiser for `SerialStampedCachingDecorator` when the value is an array of `T`.
    ///
    /// - Parameters:
    ///   - decoratee: The remote loader function.
    ///   - save: The function to save data locally.
    convenience init<T>(
        decoratee: @escaping RemoteDecoratee<T>,
        save: @escaping Save<T>
    ) where Value == [T] {
        
        self.init(
            decoratee: { serial, completion in
                
                decoratee(serial) { result in
                    
                    completion(result.map { response in
                            .init(value: response.list, serial: response.serial)
                    })
                }
            },
            cache: { payload, completion in
                
                save(payload.value, payload.serial, completion)
            }
        )
    }
}
