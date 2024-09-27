//
//  CategoryPickerSectionFlowEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public struct CategoryPickerSectionFlowEffectHandlerMicroServices<Select, Navigation> {
    
    public let getNavigation: GetNavigation
    
    public init(
        getNavigation: @escaping GetNavigation
    ) {
        self.getNavigation = getNavigation
    }
}

public extension CategoryPickerSectionFlowEffectHandlerMicroServices {
    
    typealias GetNavigation = (Select, @escaping (Navigation) -> Void) -> Void
}
