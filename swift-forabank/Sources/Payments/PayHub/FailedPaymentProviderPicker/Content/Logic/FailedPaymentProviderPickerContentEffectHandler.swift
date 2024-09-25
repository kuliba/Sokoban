//
//  FailedPaymentProviderPickerContentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.09.2024.
//

public final class FailedPaymentProviderPickerContentEffectHandler {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = FailedPaymentProviderPickerContentEffectHandlerMicroServices
}

public extension FailedPaymentProviderPickerContentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
            
        }
    }
}

public extension FailedPaymentProviderPickerContentEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FailedPaymentProviderPickerContentEvent
    typealias Effect = FailedPaymentProviderPickerContentEffect
}
