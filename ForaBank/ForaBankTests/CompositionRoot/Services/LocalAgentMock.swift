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
/// Additionally, `LocalAgentMock` tracks the values passed to `store(_:)` calls
/// for verification in tests. This enables confirmation that the expected data was stored,
/// along with any provided serial.
///
/// **Overwriting behavior:**
/// If multiple instances of the same type are provided in the initialization array, only the
/// last one (and its associated serial) will be returned when `load(_:)` or `serial(for:)`
/// is called for that type.
final class LocalAgentMock {
    
    /// Stored return values keyed by their types. Each entry consists of a tuple:
    /// `(value: Any, serial: String?)`.
    ///
    /// `ObjectIdentifier(type)` uniquely identifies each type.
    private let returnValues: [ObjectIdentifier: (Any, String?)]
    
    /// Records all types requested via the `load(_:)` method.
    private(set) var requestedTypes: [Any.Type] = []
    
    /// Records all values stored via the `store(_:)` method, along with their associated serials.
    private(set) var storedValues: [(Encodable, String?)] = []
    
    /// Initializes the mock with a set of decodable values and their associated serials,
    /// which will be returned on subsequent `load(_:)` calls.
    ///
    /// - Parameter stubs: An array of `(Decodable, String?)` tuples. Each value is keyed
    ///                    internally by its dynamic type. If multiple values of the same
    ///                    type appear, the last one overwrites the previous value and serial.
    init(stubs: [(any Decodable, String?)] = []) {
        
        self.returnValues = .init(
            stubs.map { (ObjectIdentifier(type(of: $0.0)), ($0.0, $0.1)) },
            uniquingKeysWith: { _, last in last }
        )
    }
}

extension LocalAgentMock: LocalAgentProtocol {
    
    /// Loads a previously configured `Decodable` value of the given type.
    ///
    /// - Parameter type: The type to load.
    /// - Returns: The previously configured value of this type, or `nil` if none was provided.
    func load<T: Decodable>(type: T.Type) -> T? {
        
        requestedTypes.append(type)
        return returnValues[ObjectIdentifier(type)]?.0 as? T
    }
    
    /// Stores an `Encodable` value. In this mock, it records the value and the provided serial.
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
    /// **Note:** This mock does not implement clearing behavior. Calling this method
    /// will result in an unimplemented error.
    ///
    /// - Parameter type: The type to clear.
    /// - Throws: Always throws an unimplemented error in this mock.
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
    
    /// Retrieves the file name associated with a given type.
    ///
    /// - Parameter type: The type whose file name is requested.
    /// - Returns: A string representation of the type.
    func fileName<T>(for type: T.Type) -> String {
        
        // Placeholder implementation
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
        self.init(stubs: typedValues)
    }
}

extension LocalAgentMock {
    
    /// The number of times `load(_:)` has been called, derived from the count of `requestedTypes`.
    var loadCallCount: Int { requestedTypes.count }
    
    /// The number of times `store(_:)` has been called, derived from the count of `storedValues`.
    var storeCallCount: Int { storedValues.count }
    
    /// A computed property that returns the types of all values passed to `store(_:)`.
    var storedTypes: [Any.Type] { storedValues.map { type(of: $0.0) } }
    
    /// Retrieves all stored values of a specific `Encodable` type.
    ///
    /// - Parameter type: The `Encodable` type to filter stored values.
    /// - Returns: An array of stored values of the specified type.
    func getStoredValues<T: Encodable>(ofType type: T.Type) -> [T] {
        
        return storedValues.compactMap { $0.0 as? T }
    }
    
    /// Retrieves all stored serials associated with a specific `Encodable` type.
    ///
    /// - Parameter type: The `Encodable` type whose serials are to be retrieved.
    /// - Returns: An array of serials associated with the stored values of the specified type.
    func getStoredSerials<T: Encodable>(forType type: T.Type) -> [String?] {
        
        return storedValues
            .filter { $0.0 is T }
            .map { $0.1 }
    }
    
    /// Checks if a specific `Encodable` type has been stored.
    ///
    /// - Parameter type: The `Encodable` type to check.
    /// - Returns: `true` if at least one value of the specified type has been stored; otherwise, `false`.
    func hasStoredValues<T: Encodable>(ofType type: T.Type) -> Bool {
        
        return storedValues.contains { $0.0 is T }
    }
    
    /// Retrieves the first stored value of a specific `Encodable` type, if any.
    ///
    /// - Parameter type: The `Encodable` type to retrieve.
    /// - Returns: The first stored value of the specified type, or `nil` if none exists.
    func firstStoredValue<T: Encodable>(ofType type: T.Type) -> T? {
        
        return storedValues.first { $0.0 is T }?.0 as? T
    }
    
    /// Retrieves the last stored value of a specific `Encodable` type, if any.
    ///
    /// - Parameter type: The `Encodable` type to retrieve.
    /// - Returns: The last stored value of the specified type, or `nil` if none exists.
    func lastStoredValue<T: Encodable>(ofType type: T.Type) -> T? {
        
        return storedValues.last { $0.0 is T }?.0 as? T
    }
    
    /// Retrieves all stored values along with their associated serials for a specific `Encodable` type.
    ///
    /// - Parameter type: The `Encodable` type to filter stored values.
    /// - Returns: An array of tuples containing the stored values and their serials.
    func getStoredValuesWithSerials<T: Encodable>(ofType type: T.Type) -> [(T, String?)] {
        
        return storedValues
            .compactMap {
                if let value = $0.0 as? T {
                    return (value, $0.1)
                }
                return nil
            }
    }
}
