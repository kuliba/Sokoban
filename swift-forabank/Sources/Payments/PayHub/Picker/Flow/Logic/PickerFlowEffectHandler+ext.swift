//
//  PickerFlowEffectHandler+ext.swift
//  
//
//  Created by Igor Malyarov on 04.09.2024.
//

public extension PickerFlowEffectHandler {
    
    convenience init(
        makeNavigation: @escaping (Element, @escaping (Navigation) -> Void) -> Void
    ) {
        self.init(makeNavigation: { element, _, completion in
            
            makeNavigation(element, completion)
        })
    }
}
