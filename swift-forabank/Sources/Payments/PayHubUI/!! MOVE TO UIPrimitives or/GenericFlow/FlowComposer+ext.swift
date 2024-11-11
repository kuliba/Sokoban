//
//  FlowComposer+ext.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import CombineSchedulers
import Foundation
import PayHub

public extension FlowComposer {
    
    convenience init(
        getNavigation: @escaping MicroServices.GetNavigation,
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.init(
            microServices: .init(getNavigation: getNavigation),
            scheduler: scheduler,
            interactiveScheduler: interactiveScheduler
        )
    }
}
