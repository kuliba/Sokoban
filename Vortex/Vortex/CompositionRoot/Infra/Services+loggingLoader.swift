//
//  Services+loggingLoader.swift
//  Vortex
//
//  Created by Igor Malyarov on 04.02.2024.
//

import Foundation
import GenericLoader

extension Services {
    
    typealias Log = (LoggerAgentLevel, String, StaticString, UInt) -> ()
    
    static func loggingLoader<T>(
        store: any Store<T>,
        log: @escaping Log,
        currentDate: @escaping () -> Date = Date.init
    ) -> any Loader<T> {
        
        LoggingLoaderDecorator(
            decoratee: LoaderOf(
                store: store,
                currentDate: currentDate
            ),
            log: log
        )
    }
}
