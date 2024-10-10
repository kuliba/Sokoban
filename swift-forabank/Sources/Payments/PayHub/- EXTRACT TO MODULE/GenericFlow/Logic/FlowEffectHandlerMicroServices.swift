//
//  FlowEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public struct FlowEffectHandlerMicroServices<Select, Navigation> {
    
    public let getNavigation: GetNavigation
    
    public init(
        getNavigation: @escaping GetNavigation
    ) {
        self.getNavigation = getNavigation
    }
}

public extension FlowEffectHandlerMicroServices {
    
    typealias Event = FlowEvent<Select, Navigation>
    typealias Notify = (Event) -> Void
    typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
}

public extension FlowEffectHandlerMicroServices {
    
    typealias GetNavigationWithoutNotify = (Select, @escaping (Navigation) -> Void) -> Void
    
    init(
        getNavigation: @escaping GetNavigationWithoutNotify
    ) {
        self.getNavigation = { getNavigation($0, $2) }
    }
}
