//
//  SerialStampedCachingDecorator+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.09.2024.
//

import ForaTools
import RemoteServices

extension SerialStampedCachingDecorator {
    
    typealias RemoteDecorateeCompletion<T> = (Result<RemoteServices.SerialStamped<T>, Error>) -> Void
    typealias RemoteDecoratee<T> = (String?, @escaping RemoteDecorateeCompletion<T>) -> Void
    typealias Save<T> = ([T], Serial, @escaping CacheCompletion) -> Void
    
    convenience init<T>(
        decoratee: @escaping RemoteDecoratee<T>,
        save: @escaping Save<T>
    ) where Response == [T] {
        
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
