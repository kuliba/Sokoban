//
//  PlainPickerFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PlainPickerFlowEffectHandler<Element, Navigation> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PlainPickerFlowEffectHandlerMicroServices<Element, Navigation>
}

public extension PlainPickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(element):
            microServices.makeNavigation(element) {
                
                dispatch(.navigation($0))
            }
        }
    }
}

public extension PlainPickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PlainPickerFlowEvent<Element, Navigation>
    typealias Effect = PlainPickerFlowEffect<Element>
}
