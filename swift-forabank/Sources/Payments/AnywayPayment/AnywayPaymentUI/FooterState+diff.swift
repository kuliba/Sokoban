//
//  FooterState+diff.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import AmountComponent

public extension FooterState {
    
    func diff(from old: Self?) -> Projection? {
        
        guard let old else { return nil }
        
        if button.state != old.button.state,
           button.state == .tapped {
            
            return .buttonTapped
        }
        
        if old.amount != amount {
            
            return .amount(amount)
        }
        
        return nil
    }
}
