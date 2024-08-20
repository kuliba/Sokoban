//
//  LoadablePickerEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

struct LoadablePickerEffectHandlerMicroServices<Element> {
    
    let load: Load
}

extension LoadablePickerEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Element], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}
