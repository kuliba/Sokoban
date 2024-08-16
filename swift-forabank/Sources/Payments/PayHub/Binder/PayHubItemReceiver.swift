//
//  PayHubItemReceiver.swift
//  
//
//  Created by Igor Malyarov on 16.08.2024.
//

// However tempting, do not try to make it super-generic - over receiving type - protocol conformance could be stated just once even for different generic shapes.
public protocol PayHubItemReceiver<Latest> {
    
    associatedtype Latest
    
    typealias Item = PayHubItem<Latest>

    func receive(_: Item?)
}
