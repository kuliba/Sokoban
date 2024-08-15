//
//  PayHubEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

struct PayHubEffectHandlerMicroServices<Exchange, Latest, LatestFlow, Templates> {
    
    let load: Load
    let makeExchange: MakeExchange
    let makeLatestFlow: MakeLatestFlow
    let makeTemplates: MakeTemplates
}

extension PayHubEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Latest], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias MakeExchange = () -> Exchange
    typealias MakeLatestFlow = (Latest) -> LatestFlow
    typealias MakeTemplates = () -> Templates
}
