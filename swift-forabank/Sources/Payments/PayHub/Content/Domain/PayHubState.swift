//
//  PayHubState.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public typealias PayHubState<Latest> = Optional<LoadedPayHubState<Latest>>

public struct LoadedPayHubState<Latest> {
    
    public let items: [Item]
    public var selected: Item?
    
    public init(
        items: [Item], 
        selected: Item? = nil
    ) {
        self.items = items
        self.selected = selected
    }
    
    public typealias Item = PayHubItem<Latest>
}

extension LoadedPayHubState: Equatable where Latest: Equatable {}
