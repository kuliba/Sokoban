//
//  LoadablePickerState.swift
//  
//
//  Created by Igor Malyarov on 20.08.2024.
//

public struct LoadablePickerState<ID, Element>
where ID: Hashable {
    
    internal var prefix: [Item]
    internal var suffix: [Item]
    public var selected: Element?
    
    public init(
        prefix: [Item],
        suffix: [Item],
        selected: Element? = nil
    ) {
        self.prefix = prefix
        self.suffix = suffix
        self.selected = selected
    }
    
    public enum Item {
        
        case element(Identified<ID, Element>)
        case placeholder(ID)
    }
}

public extension LoadablePickerState {
    
    var items: [Item] { prefix + suffix }
    
    var elements: [Identified<ID, Element>] {
        
        items.compactMap {
            
            guard case let .element(element) = $0
            else { return nil }
            
            return element
        }
    }
    
    var placeholderIDs: [ID] {
        
        items.compactMap {
            
            guard case let .placeholder(id) = $0
            else { return nil }
            
            return id
        }
    }
    
    // presuming placeholders are used during load
    // otherwise `isLoading` should be stored property
    var isLoading: Bool { !placeholderIDs.isEmpty }
}

extension LoadablePickerState.Item: Identifiable {
    
    public var id: ID {
        
        switch self {
        case let .element(element): return element.id
        case let .placeholder(id):  return id
        }
    }
}

extension LoadablePickerState: Equatable where ID: Equatable, Element: Equatable {}
extension LoadablePickerState.Item: Equatable where ID: Equatable, Element: Equatable {}
