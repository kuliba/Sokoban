//
//  PayHubItem.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubItem<Exchange, Latest, Templates> {
    
    case exchange(Node<Exchange>)
    case latest(Node<Latest>)
    case templates(Node<Templates>)
}

extension PayHubItem: Equatable where Exchange: Equatable, Latest: Equatable, Templates: Equatable {}
