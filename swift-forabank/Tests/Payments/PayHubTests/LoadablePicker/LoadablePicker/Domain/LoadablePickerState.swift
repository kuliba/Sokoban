//
//  LoadablePickerState.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

import PayHub

struct LoadablePickerState<ID, Element>
where ID: Hashable {
    
    internal var prefix: [Item]
    internal var suffix: [Item]
    var selected: Element?
    
    init(
        prefix: [Item],
        suffix: [Item],
        selected: Element? = nil
    ) {
        self.prefix = prefix
        self.suffix = suffix
        self.selected = selected
    }
}

extension LoadablePickerState {
    
    var items: [Item] { prefix + suffix }
    
    enum Item {
        
        case element(Identified<ID, Element>)
        case placeholder(ID)
    }
}

extension LoadablePickerState.Item: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .element(element): return element.id
        case let .placeholder(id):  return id
        }
    }
}

extension LoadablePickerState: Equatable where ID: Equatable, Element: Equatable {}
extension LoadablePickerState.Item: Equatable where ID: Equatable, Element: Equatable {}
