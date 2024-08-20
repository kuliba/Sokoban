//
//  LoadablePickerEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

public struct LoadablePickerEffectHandlerMicroServices<Element> {
    
    public let load: Load
    
    public init(
        load: @escaping Load
    ) {
        self.load = load
    }
}

public extension LoadablePickerEffectHandlerMicroServices {
    
    typealias LoadCompletion = ([Element]) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}
