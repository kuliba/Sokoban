//
//  AnyLoader+ext.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

public extension AnyLoader {
    
    /// Initialises a new instance of `AnyLoader` by wrapping an existing loader.
    ///
    /// This initialiser provides a convenient way to create an `AnyLoader` from any existing loader that conforms to the `Loader` protocol.
    ///
    /// - Parameter loader: An existing loader that conforms to the `Loader` protocol.
    init(_ loader: any Loader<Payload, Response>) {
        
        self.init(loader.load(_:_:))
    }
}
