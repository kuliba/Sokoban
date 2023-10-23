//
//  GenericLoaderOf+loggingStore.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import CVVPINServices
import Foundation

extension GenericLoaderOf where Local == Model {
    
    convenience init(
        loggingStore: any Store<Model>,
        currentDate: @escaping CurrentDate = Date.init
    ) {
        self.init(
            store: LoggingStoreDecorator(decoratee: loggingStore),
            toModel: { $0 },
            toLocal: { $0 },
            currentDate: currentDate
        )
    }
}
