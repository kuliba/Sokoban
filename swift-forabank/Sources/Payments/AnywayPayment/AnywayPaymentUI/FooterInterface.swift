//
//  FooterInterface.swift
//
//
//  Created by Igor Malyarov on 22.06.2024.
//

import AmountComponent
import Combine
import Foundation

public protocol FooterInterface: AnyObject {
    
    var projectionPublisher: AnyPublisher<Projection, Never> { get }
    
    func project(_ projection: FooterTransactionProjection)
}

public enum Projection: Equatable {
    
    case amount(Decimal)
    case buttonTapped
}

public struct FooterTransactionProjection: Equatable {
    
    public let isEnabled: Bool
    public let style: FooterState.Style
    
    public init(
        isEnabled: Bool,
        style: FooterState.Style
    ) {
        self.isEnabled = isEnabled
        self.style = style
    }
}
