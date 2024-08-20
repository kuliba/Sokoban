//
//  LoadablePickerEffectHandler.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

final class LoadablePickerEffectHandler<Element> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = LoadablePickerEffectHandlerMicroServices<Element>
}

extension LoadablePickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            microServices.load { [weak self] in
                
                guard self != nil else { return }
                
                dispatch(.loaded(((try? $0.get()) ?? [])))
            }
        }
    }
}

extension LoadablePickerEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = LoadablePickerEvent<Element>
    typealias Effect = LoadablePickerEffect
}
