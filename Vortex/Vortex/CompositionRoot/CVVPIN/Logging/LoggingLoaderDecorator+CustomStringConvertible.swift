//
//  LoggingLoaderDecorator+CustomStringConvertible.swift
//  Vortex
//
//  Created by Igor Malyarov on 02.11.2023.
//

extension LoggingLoaderDecorator: CustomStringConvertible {
    
    var description: String { "LoaderDecorator<\(T.self)>" }
}
