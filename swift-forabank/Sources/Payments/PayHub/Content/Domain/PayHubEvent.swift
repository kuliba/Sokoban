//
//  PayHubEvent.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubEvent<Element> {
    
    case load
    case loaded([Element])
    case select(PayHubItem<Element>?)
}

extension PayHubEvent: Equatable where Element: Equatable {}
