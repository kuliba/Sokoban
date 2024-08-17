//
//  PayHubState.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

import Foundation

public struct PayHubState<Element> {
    
    public var loadState: LoadState
    public var selected: Item?
    
    public init(
        loadState: LoadState, 
        selected: Item? = nil
    ) {
        self.loadState = loadState
        self.selected = selected
    }
    
    public enum LoadState {
        
        case loaded([Identified<UUID, Element>])
        case placeholders([UUID])
    }

    public typealias Item = PayHubItem<Element>
}

extension PayHubState: Equatable where Element: Equatable {}
extension PayHubState.LoadState: Equatable where Element: Equatable {}
