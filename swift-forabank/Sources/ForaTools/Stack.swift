//
//  Stack.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

public struct Stack<Element> {
    
    private var elements = [Element]()
    
    public init(_ elements: Element...) {
        
        self.elements = elements
    }
    
    public init(_ elements: [Element]) {
        
        self.elements = elements
    }
}

public extension Stack {
    
    var last: Element? {
        
        get { peek() }
        
        set(newValue) {
            
            if elements.endIndex > 0 {
                if let newValue {
                    elements[elements.endIndex - 1] = newValue
                } else {
                    elements.removeLast()
                }
            } else {
                if let newValue {
                    elements = [newValue]
                }
            }
        }
    }
}

public extension Stack {
    
    func peek() -> Element? {
        
        elements.last
    }
    
    @discardableResult
    mutating func pop() -> Element? {
        
        elements.popLast()
    }
    
    mutating func push(_ element: Element) {
        
        elements.append(element)
    }
}

public extension Stack {
    
    var count: Int { elements.count }
    
    var isEmpty: Bool { count == 0 }
}

extension Stack: Equatable where Element: Equatable {}
