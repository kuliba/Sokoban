//
//  FooterInterface.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import Combine
import Foundation

public protocol FooterInterface: AnyObject {
    
    var projectionPublisher: AnyPublisher<FooterProjection, Never> { get }
    
    func enableButton(_ isEnabled: Bool)
}

public struct FooterProjection: Equatable {
    
    public let amount: Decimal
    public let buttonTap: ButtonTap?
    
    public init(
        amount: Decimal,
        buttonTap: ButtonTap?
    ) {
        self.amount = amount
        self.buttonTap = buttonTap
    }
    
    public struct ButtonTap: Equatable {
        
        public init() {}
    }
}
