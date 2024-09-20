//
//  LoadablePickerEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

public final class LoadablePickerEffectHandler<Element> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = LoadablePickerEffectHandlerMicroServices<Element>
}

public extension LoadablePickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            microServices.load { [weak self] in
                
                guard self != nil else { return }
                
                dispatch(.loaded($0))
            }
        }
    }
}

public extension LoadablePickerEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = LoadablePickerEvent<Element>
    typealias Effect = LoadablePickerEffect
}
