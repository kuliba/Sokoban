//
//  PlainPickerState.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public struct PlainPickerState<Element> {
    
    public let elements: [Element]
    public var selection: Element?
    
    public init(
        elements: [Element], 
        selection: Element? = nil
    ) {
        self.elements = elements
        self.selection = selection
    }
}

extension PlainPickerState: Equatable where Element: Equatable {}
