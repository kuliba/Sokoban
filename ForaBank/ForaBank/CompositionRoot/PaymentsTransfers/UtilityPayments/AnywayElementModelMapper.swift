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
    
    typealias Event = AnywayPaymentEvent
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
                return .widget(.otp(makeModelForOTP(with:otp)))
            }
            
        default:
            fatalError("impossible case; would be removed on change to models")
        }
    }
}

private extension AnywayElementModelMapper {
    
#warning("extract?")
    func makeModelForOTP(
        with otp: Int?
    ) -> AnywayElementModel.Widget.OTPViewModel {
        
        return .init(
            initialState: .init(value: otp),
            reduce: { _, event in
                
                switch event {
                case let .input(input):
                    let digits = input.filter(\.isWholeNumber).prefix(6)
                    return (.init(value: Int(digits)), nil)
                }
            },
            handleEffect: { _,_ in },
            observe: { [weak self] in
                
                self?.event(.widget(.otp($0.value.map { "\($0)" } ?? "")))
            }
        )
    }
}
