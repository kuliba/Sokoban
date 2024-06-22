//
//  FooterEvent.swift
//
//
//  Created by Igor Malyarov on 21.06.2024.
//

import Foundation

public enum FooterEvent: Equatable {
    
    case button(ButtonEvent)
    case edit(Decimal)
    case style(Style)
    case title(String)
    case set(isActive: Bool, Style)

    public enum ButtonEvent: Equatable {
        
        case disable, enable, tap
    }
    
    public typealias Style = FooterState.Style
}
