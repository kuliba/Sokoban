//
//  PayHubEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public struct PayHubEffectHandlerMicroServices<Exchange, Latest, LatestFlow, Templates> {
    
    public let load: Load
    public let makeExchange: MakeExchange
    public let makeLatestFlow: MakeLatestFlow
    public let makeTemplates: MakeTemplates
    
    public init(
        load: @escaping Load,
        makeExchange: @escaping MakeExchange,
        makeLatestFlow: @escaping MakeLatestFlow,
        makeTemplates: @escaping MakeTemplates
    ) {
        self.load = load
        self.makeExchange = makeExchange
        self.makeLatestFlow = makeLatestFlow
        self.makeTemplates = makeTemplates
    }
}

public extension PayHubEffectHandlerMicroServices {
    
    typealias LoadResult = Result<[Latest], Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias MakeExchange = () -> Exchange
    typealias MakeLatestFlow = (Latest) -> LatestFlow
    typealias MakeTemplates = () -> Templates
}
