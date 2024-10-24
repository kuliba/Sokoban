//
//  Loader+ext.swift
//
//
//  Created by Igor Malyarov on 12.10.2024.
//

import Foundation

public extension Loader where Local == Model {
    
    convenience init(
        store: any Store<Model>,
        currentDate: @escaping CurrentDate = Date.init
    ) {
        self.init(
            store: store,
            toModel: { $0 },
            toLocal: { $0 },
            currentDate: currentDate
        )
    }
}
