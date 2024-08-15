//
//  PayHubFlowEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public struct PayHubFlowEffectHandlerMicroServices<Exchange, Latest, LatestFlow, Templates> {
    
    public let makeExchange: MakeExchange
    public let makeLatestFlow: MakeLatestFlow
    public let makeTemplates: MakeTemplates
    
    public init(
        makeExchange: @escaping MakeExchange,
        makeLatestFlow: @escaping MakeLatestFlow,
        makeTemplates: @escaping MakeTemplates
    ) {
        self.makeExchange = makeExchange
        self.makeLatestFlow = makeLatestFlow
        self.makeTemplates = makeTemplates
    }
}

public extension PayHubFlowEffectHandlerMicroServices {
    
    typealias MakeExchange = () -> Exchange
    typealias MakeLatestFlow = (Latest) -> LatestFlow
    typealias MakeTemplates = () -> Templates
}
