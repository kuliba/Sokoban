//
//  FlowEffectHandler+MicroServices.swift
//
//
//  Created by Igor Malyarov on 13.12.2024.
//

import CombineSchedulers
import Foundation

public extension FlowEffectHandler {
    
    @available(*, deprecated, message: "Use designated initializer with `getNavigation` closure for brevity and clarity.")
    convenience init(
        delay: Delay = .milliseconds(100),
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) {
        self.init(delay: delay, getNavigation: microServices.getNavigation, scheduler: scheduler)
    }
    
    typealias MicroServices = FlowEffectHandlerMicroServices<Select, Navigation>
}
