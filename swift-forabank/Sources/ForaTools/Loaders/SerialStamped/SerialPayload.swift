//
//  SerialPayload.swift
//
//
//  Created by Igor Malyarov on 15.09.2024.
//

/// An enumeration that encapsulates either a direct `Serial` value or a type conforming to `WithSerial`.
public enum SerialPayload<Serial> {
    
    case serial(Serial)
    case withSerial(any WithSerial<Serial>)
}

public extension SerialPayload {
    
    /// The serial associated with the payload.
    var serial: Serial {
        switch self {
        case .serial(let serial):
            return serial
        case .withSerial(let withSerial):
            return withSerial.serial
        }
    }
}
