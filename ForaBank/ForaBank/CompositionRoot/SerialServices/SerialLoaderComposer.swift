//
//  SerialLoaderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.09.2024.
//

import ForaTools
import Foundation
import RemoteServices

final class SerialLoaderComposer {
    
    private let localComposer: LocalLoaderComposer
    private let nanoServiceComposer: LoggingRemoteNanoServiceComposer
    
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

#warning("make private after `RootViewModelFactory+makeLoadServiceCategories` delete")
/*private*/ extension SerialStampedCachingDecorator {
    
    typealias RemoteDecorateeCompletion<T> = (Result<RemoteServices.SerialStamped<Serial, T>, Error>) -> Void
    typealias RemoteDecoratee<T> = (Serial?, @escaping RemoteDecorateeCompletion<T>) -> Void
    typealias Save<T> = ([T], Serial, @escaping CacheCompletion) -> Void
    
    convenience init<T>(
        decoratee: @escaping RemoteDecoratee<T>,
        save: @escaping Save<T>
    ) where Value == [T] {
        
        self.init(
            decoratee: { serial, completion in
                
                decoratee(serial) {
                    
                    completion($0.map {
                        
                        .init(value: $0.list, serial: $0.serial)
                    })
                }
            },
            cache: { payload, completion in
                
                save(payload.value, payload.serial, completion)
            }
        )
    }
}
