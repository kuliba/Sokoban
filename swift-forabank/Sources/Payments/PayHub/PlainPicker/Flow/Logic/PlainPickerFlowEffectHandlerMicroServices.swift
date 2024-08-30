//
//  PlainPickerFlowEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public struct PlainPickerFlowEffectHandlerMicroServices<Element, Navigation> {
    
    public let makeNavigation: MakeNavigation
    
    public init(
        makeNavigation: @escaping MakeNavigation
    ) {
        self.makeNavigation = makeNavigation
    }
}

public extension PlainPickerFlowEffectHandlerMicroServices {
    
    typealias MakeNavigation = (Element, @escaping (Navigation) -> Void) -> Void
}
