//
//  PickerFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public final class PickerFlowEffectHandler<Element, Navigation> {
    
    public let makeNavigation: MakeNavigation
    
    public init(
        makeNavigation: @escaping MakeNavigation
    ) {
        self.makeNavigation = makeNavigation
    }
    
    public typealias MakeNavigation = (Element, @escaping (Navigation) -> Void) -> Void
}

public extension PickerFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(element):
            makeNavigation(element) { dispatch(.navigation($0)) }
        }
    }
}

public extension PickerFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PickerFlowEvent<Element, Navigation>
    typealias Effect = PickerFlowEffect<Element>
}
