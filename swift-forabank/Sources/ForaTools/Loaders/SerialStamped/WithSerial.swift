//
//  WithSerial.swift
//
//
//  Created by Igor Malyarov on 15.09.2024.
//

public protocol WithSerial<Serial> {
    
    associatedtype Serial
    
    var serial: Serial { get }
}
