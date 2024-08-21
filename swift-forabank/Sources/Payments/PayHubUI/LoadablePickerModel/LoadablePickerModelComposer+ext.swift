//
//  LoadablePickerModelComposer+ext.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation

public extension LoadablePickerModelComposer
where ID == UUID {
    
    convenience init(
        load: @escaping Load,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.init(load: load, makeID: UUID.init, scheduler: scheduler)
    }
}
