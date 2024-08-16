//
//  PayHubItemSelector.swift
//
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Combine

// However tempting, do not try to make it super-generic - over selecting type - protocol conformance could be stated just once even for different generic shapes.
public protocol PayHubItemSelector<Latest> {
    
    associatedtype Latest
    
    typealias Item = PayHubItem<Latest>
    
    var selectPublisher: AnyPublisher<Item?, Never> { get }
}
