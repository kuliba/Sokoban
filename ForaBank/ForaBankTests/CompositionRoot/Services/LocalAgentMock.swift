//
//  LocalAgentMock.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 08.12.2024.
//

@testable import ForaBank

/// A mock implementation of `LocalAgentProtocol` used for testing purposes.
///
/// `LocalAgentMock` allows you to pre-load return values (with optional serials) for specific
/// `Decodable` types by providing an array of `(Decodable, String?)` tuples at initialization.
/// When `load(_:)` is called, it returns the value that matches the requested type.
///
/// Additionally, `LocalAgentMock` keeps track of the values passed to `store(_:)` calls
/// for verification in tests. This lets you confirm that the expected data was stored,
/// along with the provided serial if any.
///
/// **Overwriting behavior:**
/// If multiple instances of the same type are provided in the initialization array, only the
/// last one (and its associated serial) will be returned when `load(_:)` or `serial(for:)`
/// is called for that type.
final class LocalAgentMock: LocalAgentProtocol {
    
    /// The stored return values keyed by their types. Each entry consists of a tuple:
    /// `(value: Any, serial: String?)`.
    ///
    /// `ObjectIdentifier(type)` is used as a key to uniquely identify each type.
    private let returnValues: [ObjectIdentifier: (Any, String?)]
    
    /// A record of all requested types via the `load(_:)` method.
    private(set) var requestedTypes: [Any.Type] = []
    
    /// A record of all stored values via the `store(_:)` method, including the provided serial.
    private(set) var storedValues: [(Encodable, String?)] = []
    
    /// Initializes the mock with a set of decodable values and their associated serials,
    /// which will be returned on subsequent `load(_:)` calls.
    ///
    /// - Parameter values: An array of `(Decodable, String?)` tuples. Each value is keyed
    ///                     internally by its dynamic type. If multiple values of the same
    ///                     type appear, the last one overwrites the previous value and serial.
    init(values: [(any Decodable, String?)] = []) {
        
        self.returnValues = .init(
            values.map { (ObjectIdentifier(type(of: $0.0)), ($0.0, $0.1)) },
            uniquingKeysWith: { _, last in last }
        )
    }
    
    /// The number of times `load(_:)` has been called. This is derived from the size of `requestedTypes`.
    var loadCallCount: Int { requestedTypes.count }
    
    /// The number of times `store(_:)` has been called. This is derived from the size of `storedValues`.
    var storeCallCount: Int { storedValues.count }
    
    /// A computed property that returns the types of all values passed to `store(_:)`.
    var storedTypes: [Any.Type] { storedValues.map { type(of: $0.0) }}
    
    /// Loads a previously configured `Decodable` value of the given type.
    ///
    /// - Parameter type: The type to load.
    /// - Returns: The previously configured value of this type, or `nil` if none was provided.
    func load<T: Decodable>(type: T.Type) -> T? {
        
        requestedTypes.append(type)
        return returnValues[ObjectIdentifier(type)]?.0 as? T
    }
    
    /// Stores an `Encodable` value. In this mock, it simply records the value and the provided serial.
    ///
    /// - Parameters:
    ///   - data: The value to store.
    ///   - serial: An optional serial associated with the data.
    /// - Throws: This implementation does not throw by default, but can be modified for testing error scenarios.
    func store<T: Encodable>(_ data: T, serial: String?) throws {
        
        storedValues.append((data, serial))
    }
    
    /// Clears the data for a given type.
    ///
    /// **Note:** This mock currently does not implement clearing behavior. Calling this method
    /// will result in an unimplemented error.
    ///
    /// - Parameter type: The type to clear.
    /// - Throws: Always throws unimplemented error in this mock.
    func clear<T>(type: T.Type) throws {
        
        let _: T = unimplemented()
    }
    
    /// Retrieves the serial associated with a previously configured type.
    ///
    /// - Parameter type: The type whose serial is requested.
    /// - Returns: The serial associated with the given type, or `nil` if none was provided.
    func serial<T>(for type: T.Type) -> String? {
        
        return returnValues[ObjectIdentifier(type)]?.1
    }
    
    func fileName<T>(for type: T.Type) -> String {
        
        // Example placeholder implementation
        return "\(type)"
    }
}

extension LocalAgentMock {
    
    /// A convenience initializer that takes an array of `Decodable` instances and presumes their serials are `nil`.
    ///
    /// - Parameter values: An array of `Decodable` values. Each value is keyed internally by its dynamic type.
    ///                     If multiple values of the same type appear, the last one overwrites the previous value.
    convenience init(values: [any Decodable]) {
        
        let typedValues = values.map { ($0, nil as String?) }
        self.init(values: typedValues)
    }
}
