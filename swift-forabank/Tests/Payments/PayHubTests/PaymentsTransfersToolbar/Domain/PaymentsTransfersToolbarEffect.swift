//
//  PaymentsTransfersToolbarEffect.swift
//
//
//  Created by Igor Malyarov on 22.08.2024.
//

enum PaymentsTransfersToolbarEffect: Equatable {
    
    case select(Select)
}

extension PaymentsTransfersToolbarEffect {
    
    enum Select {
        
        case profile, qr
    }
}
