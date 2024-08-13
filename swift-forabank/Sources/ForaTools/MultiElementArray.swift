//
//  MultiElementArray.swift
//
//
//  Created by Igor Malyarov on 26.04.2024.
//

/// `MultiElementArray` is a generic collection that enforces the presence of more than one element.
/// This struct is useful for scenarios where business logic requires at least two elements in the collection
/// to function correctly, such as in algorithms that compare elements or require multiple inputs.
///
/// The `MultiElementArray` does not allow initialisation with zero or one element, thus ensuring the array
/// always contains multiple elements, which reduces the need for repeated validation checks throughout the code.
///
/// Usage:
/// ```
/// if let array = MultiElementArray(["item1", "item2"]) {
///     print(array.elements)  // Output: ["item1", "item2"]
/// } else {
///     print("Initialisation failed.")
/// }
/// ```
///
/// - Parameter Element: The type of elements the array holds.
///
/// Properties:
/// - `elements`: A read-only array of type `[Element]` that returns the elements of the `MultiElementArray`.
// TODO: implement `Collection` protocol conformance.
public struct MultiElementArray<Element> {
    
    private var _elements: [Element]
    
    /// Initialises a `MultipleArray` instance with the given array of elements.
    /// - Parameter elements: An array of `Element`. The array must contain more than one element.
    /// - Returns: An optional `MultipleArray` instance. Returns nil if the input array has one or zero elements.
    public init?(_ elements: [Element]) {
        
        guard elements.count > 1 else { return nil }
        
        self._elements = elements
    }
    
    public init(
        _ head: Element,
        _ tail: Element...
    ) {
        self._elements = [head] + tail
    }
}

extension MultiElementArray {
    
    public var elements: [Element] { _elements }
}

extension MultiElementArray: Equatable where Element: Equatable {}

extension MultiElementArray {
    
    public func map<T>(
        _ transform: (Element) throws -> T
    ) rethrows -> MultiElementArray<T> {
        
        return try .init(elements.map(transform))!
    }
    
    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        
        return .init(lhs.elements + rhs.elements)!
    }
}
