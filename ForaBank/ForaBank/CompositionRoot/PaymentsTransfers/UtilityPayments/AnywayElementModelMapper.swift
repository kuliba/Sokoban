//
//  AnywayElementModelMapper.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain

final class AnywayElementModelMapper {
    
    private let event: (Event) -> Void
    
    init(
        event: @escaping (Event) -> Void
    ) {
        self.event = event
    }
    
    typealias Event = AnywayTransactionEvent
}

extension AnywayElementModelMapper {
    
    func map(
        _ element: AnywayElement
    ) -> AnywayElementModel {
        
        switch (element, element.uiComponent) {
        case let (_, .field(field)):
            return .field(field)
            
        case let (_, .parameter(parameter)):
            return .parameter(parameter)
            
        case let (.widget(widget), _):
            switch widget {
            case let .core(core):
                return .widget(.core(core))
                
            case let .otp(otp):
                return .widget(.otp(otp))
            }
            
        default:
            fatalError("impossible case; would be removed on change to models")
        }
    }
}
