//
//  AnySerialContainer.swift
//
//
//  Created by Igor Malyarov on 15.09.2024.
//

/// A type-erased wrapper that provides access to a `serial` value.
/// It can encapsulate either a type conforming to `WithSerial` or a direct `Serial` value.
/// The optionality of `Serial` is handled by the caller via the generic parameter.
public struct AnySerialContainer<Serial> {
    
    private let _getSerial: () -> Serial
    
    /// Initialises the wrapper with a type conforming to `WithSerial`.
    ///
    /// - Parameter withSerial: An instance conforming to `WithSerial<Serial>`.
    public init<T: WithSerial>(
        _ withSerial: T
    ) where T.Serial == Serial {
        
        _getSerial = { withSerial.serial }
    }
    
    /// Initialises the wrapper with a direct `Serial?` value.
    ///
    /// - Parameter serial: An optional serial value.
    public init(
        _ serial: Serial
    ) {
        _getSerial = { serial }
    }
}

public extension AnySerialContainer {
    
    /// Retrieves the encapsulated serial value.
    var serial: Serial {
        
        return _getSerial()
    }
}
