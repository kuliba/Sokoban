//
//  PaymentsTransfersToolbarState.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

public struct PaymentsTransfersToolbarState: Equatable {
    
    public var selection: Selection?
    
    public init(
        selection: Selection? = nil
    ) {
        self.selection = selection
    }
}

public extension PaymentsTransfersToolbarState {
    
    enum Selection: Equatable {
        
        case profile, qr
    }
}
