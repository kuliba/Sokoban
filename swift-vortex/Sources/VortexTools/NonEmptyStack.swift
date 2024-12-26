//
//  NonEmptyStack.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

public struct NonEmptyStack<Element> {
    
    private var baseElement: Element
    private var elements = [Element]()
    
    public init(_ element: Element) {
        
        baseElement = element
    }
}

public extension NonEmptyStack {
    
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
    var top: Element {

        get { peek() }
        
        set(newValue) {
            
            if elements.endIndex > 0 {
                elements[elements.endIndex - 1] = newValue
            } else {
                baseElement = newValue
            }
        }
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

extension NonEmptyStack: Equatable where Element: Equatable {}
