//
//  Unimplemented.swift
//  
//
//  Created by Igor Malyarov on 19.07.2023.
//

func unimplemented<T>(_ message: String = "Unimplemented \(type(of: T.self))") -> T {
    
    fatalError(message)
}

