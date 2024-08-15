//
//  PayHubEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public struct PayHubEffectHandlerMicroServices<Latest> {
    
    public let load: Load
    
    public init(
        load: @escaping Load
    ) {
        self.load = load
    }
}

public extension PayHubEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Latest], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}
