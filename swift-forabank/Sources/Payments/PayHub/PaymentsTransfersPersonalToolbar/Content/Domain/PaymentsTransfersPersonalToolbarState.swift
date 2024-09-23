//
//  PaymentsTransfersPersonalToolbarState.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public struct PaymentsTransfersPersonalToolbarState: Equatable {
    
    public var selection: Selection?
    
    public init(
        selection: Selection? = nil
    ) {
        self.selection = selection
    }
}

public extension PaymentsTransfersPersonalToolbarState {
    
    enum Selection: Equatable {
        
        case profile, qr
    }
}
