//
//  PayHubEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

struct PayHubEffectHandlerMicroServices<Exchange, Latest, Templates> {
    
    let load: Load
    let makeExchange: MakeExchange
    let makeTemplates: MakeTemplates
}

extension PayHubEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Latest], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias MakeExchange = () -> Exchange
    typealias MakeTemplates = () -> Templates
}
