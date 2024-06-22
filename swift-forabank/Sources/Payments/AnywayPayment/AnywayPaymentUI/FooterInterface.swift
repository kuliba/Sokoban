//
//  FooterInterface.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import Combine
import Foundation

public protocol FooterInterface: AnyObject {
    
    var projectionPublisher: AnyPublisher<Projection, Never> { get }
    
    func event(_ event: FooterTransactionEvent)
}

public enum Projection: Equatable {
    
    case amount(Decimal)
    case buttonTapped
}

public enum FooterTransactionEvent: Equatable {
    
    case isEnabled(Bool)
}
