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
    
    /// The `top` property serves dual purposes:
    /// - Getter: Retrieves the top element of the stack without removing it.
    ///   Returns `nil` if the stack is empty.
    /// - Setter: Modifies the top element of the stack based on the provided value.
    ///   - If the stack is not empty:
    ///     - Assigning a non-nil value replaces the top element with this new value.
    ///     - Assigning `nil` removes the top element from the stack.
    ///   - If the stack is empty:
    ///     - Assigning a non-nil value initializes the stack with this new element.
    ///     - Assigning `nil` has no effect.
    var top: Element? {
        
        get { elements.last }
        
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
