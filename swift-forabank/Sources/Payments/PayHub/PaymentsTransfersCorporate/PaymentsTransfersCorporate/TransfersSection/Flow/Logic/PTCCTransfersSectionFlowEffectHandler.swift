//
//  PTCCTransfersSectionFlowEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 04.09.2024.
//

public final class PTCCTransfersSectionFlowEffectHandler<Navigation, Select> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = PTCCTransfersSectionFlowEffectHandlerMicroServices<Navigation, Select>
}

public extension PTCCTransfersSectionFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            microServices.makeNavigation(select) { dispatch(.navigation($0)) }
        }
    }
}

public extension PTCCTransfersSectionFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PTCCTransfersSectionFlowEvent<Navigation, Select>
    typealias Effect = PTCCTransfersSectionFlowEffect<Select>
}
