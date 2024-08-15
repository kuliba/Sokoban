//
//  PayHubItem.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubItem<Latest, TemplatesFlow> {
    
    case exchange
    case latest(Latest)
    case templates(Node<TemplatesFlow>)
}

extension PayHubItem: Equatable where Latest: Equatable, TemplatesFlow: Equatable {}
