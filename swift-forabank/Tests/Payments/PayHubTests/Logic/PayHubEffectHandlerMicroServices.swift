//
//  PayHubEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

struct PayHubEffectHandlerMicroServices<ExchangeFlow, Latest, TemplatesFlow> {
    
    let load: Load
    let makeExchange: MakeExchange
    let makeTemplates: MakeTemplates
}

extension PayHubEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Latest], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias MakeExchange = () -> ExchangeFlow
    typealias MakeTemplates = () -> TemplatesFlow
}
