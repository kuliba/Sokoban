//
//  PTCCTransfersSectionFlowEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 04.09.2024.
//

public struct PTCCTransfersSectionFlowEffectHandlerMicroServices<Navigation, Select> {
    
    public let makeNavigation: MakeNavigation
    
    public init(
        makeNavigation: @escaping MakeNavigation
    ) {
        self.makeNavigation = makeNavigation
    }
}

public extension PTCCTransfersSectionFlowEffectHandlerMicroServices {
    
    typealias MakeNavigation = (Select, @escaping (Navigation) -> Void) -> Void
}
