//
//  PayHubState.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public typealias PayHubState<Latest> = Optional<LoadedPayHubState<Latest>>

public struct LoadedPayHubState<Latest> {
    
    public let latests: [Latest]
    public var selected: Item?
    
    public init(
        latests: [Latest],
        selected: Item? = nil
    ) {
        self.latests = latests
        self.selected = selected
    }
    
    public typealias Item = PayHubItem<Latest>
}

extension LoadedPayHubState: Equatable where Latest: Equatable {}
