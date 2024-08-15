//
//  PayHubItem.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubItem<ExchangeFlow, Latest, TemplatesFlow> {
    
    case exchange(Node<ExchangeFlow>)
    case latest(Latest)
    case templates(Node<TemplatesFlow>)
}

extension PayHubItem: Equatable where ExchangeFlow: Equatable, Latest: Equatable, TemplatesFlow: Equatable {}
