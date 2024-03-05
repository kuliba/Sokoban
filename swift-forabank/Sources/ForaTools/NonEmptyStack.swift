//
//  NonEmptyStack.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

public struct NonEmptyStack<Element> {
    
    private let baseElement: Element
    private var elements = [Element]()
    
    public init(_ element: Element) {
        
        baseElement = element
    }
}

public extension NonEmptyStack {
    
    func peek() -> Element {
        
        elements.last ?? baseElement
    }
    
    @discardableResult
    mutating func pop() -> Element {
        
        elements.popLast() ?? baseElement
    }
    
    mutating func push(_ element: Element) {
        
        elements.append(element)
    }
}

public extension NonEmptyStack {
    
    var count: Int { 1 + elements.count }
    
    var isEmpty: Bool { false }
}
