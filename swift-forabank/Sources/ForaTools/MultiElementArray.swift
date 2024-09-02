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
    
    private var first: Element
    private var second: Element
    private var tail: [Element]
    
    /// Initialises a `MultiElementArray` instance with the given array of elements.
    /// - Parameter elements: An array of `Element`. The array must contain more than one element.
    /// - Returns: An optional `MultiElementArray` instance. Returns nil if the input array has one or zero elements.
    public init?(_ elements: [Element]) {
        
        guard let first = elements.first,
              let second = elements.dropFirst().first
        else { return nil }
        
        self.first = first
        self.second = second
        self.tail = .init(elements.dropFirst(2))
    }
    
    /// Initialises a `MultiElementArray` instance with at least two elements and an optional tail.
    /// - Parameters:
    ///   - first: The first element.
    ///   - second: The second element.
    ///   - tail: A variadic list of additional elements.
    public init(
        _ first: Element,
        _ second: Element,
        _ tail: Element...
    ) {
        self.init(first, second, tail)
    }
    
    /// Initialises a `MultiElementArray` instance with at least two elements and a tail array.
    /// - Parameters:
    ///   - first: The first element.
    ///   - second: The second element.
    ///   - tail: An array of additional elements.
    public init(
        _ first: Element,
        _ second: Element,
        _ tail: [Element]
    ) {
        self.first = first
        self.second = second
        self.tail = tail
    }
}

extension MultiElementArray {
    
    /// An array containing all elements in the `MultiElementArray`.
    public var elements: [Element] { [first, second] + tail }
}

extension MultiElementArray: Equatable where Element: Equatable {}

extension MultiElementArray {
    
    /// Maps each element in the `MultiElementArray` to a new `MultiElementArray` of a different type.
    /// - Parameter transform: A closure that takes an element of the array and returns a transformed value of type `T`.
    /// - Returns: A `MultiElementArray` instance containing the transformed elements.
    public func map<T>(
        _ transform: (Element) throws -> T
    ) rethrows -> MultiElementArray<T> {
        
        return try .init(elements.map(transform))!
    }
    
    /// Concatenates two `MultiElementArray` instances into one.
    /// - Parameters:
    ///   - lhs: The left-hand-side `MultiElementArray`.
    ///   - rhs: The right-hand-side `MultiElementArray`.
    /// - Returns: A new `MultiElementArray` containing the elements of both arrays.
    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        
        return .init(lhs.elements + rhs.elements)!
    }
}

public extension MultiElementArray {
    
    /// Appends a new element to the end of the `MultiElementArray`.
    /// - Parameter element: The element to append.
    mutating func append(_ element: Element) {
        
        tail.append(element)
    }
    
    /// Inserts a new element at the beginning of the `MultiElementArray`.
    /// The previous first and second elements are shifted to the right.
    /// - Parameter element: The element to insert.
    mutating func insert(_ element: Element) {
        
        tail = [second] + tail
        second = first
        first = element
    }
}
