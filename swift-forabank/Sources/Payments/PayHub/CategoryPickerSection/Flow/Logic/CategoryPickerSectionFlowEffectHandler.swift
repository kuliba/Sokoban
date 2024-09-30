//
//  CategoryPickerSectionFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public final class CategoryPickerSectionFlowEffectHandler<Select, Navigation> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = CategoryPickerSectionFlowEffectHandlerMicroServices<Select, Navigation>
}

public extension CategoryPickerSectionFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            microServices.getNavigation(select) { dispatch(.receive($0)) }
        }
    }
}

public extension CategoryPickerSectionFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CategoryPickerSectionFlowEvent<Select, Navigation>
    typealias Effect = CategoryPickerSectionFlowEffect<Select>
}
