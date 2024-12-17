//
//  FlowComposer+ext.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import CombineSchedulers
import Foundation

public extension FlowComposer {
    
    @available(*, deprecated, message: "Use designated initializer with `getNavigation` closure for brevity and clarity.")
    convenience init(
        delay: Delay = .milliseconds(100),
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.init(
            delay: delay,
            getNavigation: microServices.getNavigation,
            scheduler: scheduler,
            interactiveScheduler: interactiveScheduler
        )
    }
    
    typealias MicroServices = FlowEffectHandlerMicroServices<Select, Navigation>
}
