//
//  Stack.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

public struct Stack<Element> {
    
    private var _elements = [Element]()
    
    public init(_ elements: Element...) {
        
        self._elements = elements
    }
    
    public init(_ elements: [Element]) {
        
        self._elements = elements
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
        
        get { _elements.last }
        
        set(newValue) {
            
            if _elements.isEmpty {
                if let newValue {
                    _elements = [newValue]
                }
            } else {
                if let newValue {
                    _elements[_elements.endIndex - 1] = newValue
                } else {
                    _elements.removeLast()
                }
            }
        }
    }
    
    var count: Int { _elements.count }
    
    var isEmpty: Bool { count == 0 }
    
    var elements: [Element] { _elements }
}

public extension Stack {
    
    func peek() -> Element? {
        
        _elements.last
    }
    
    @discardableResult
    mutating func pop() -> Element? {
        
        _elements.popLast()
    }
    
    mutating func push(_ element: Element) {
        
        _elements.append(element)
    }
}

extension Stack: Equatable where Element: Equatable {}

extension Stack: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element...) {
        
        self._elements = elements
    }
}
