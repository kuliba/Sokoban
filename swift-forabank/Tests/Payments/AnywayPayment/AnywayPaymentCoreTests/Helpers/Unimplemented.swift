//
//  Unimplemented.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

func unimplemented<T>(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> T {
    
    fatalError("Unimplemented: \(message)", file: file, line: line)
}

func unimplemented<T, V>(
    _ t: T,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> V {
    
    fatalError("Unimplemented: \(message)", file: file, line: line)
}
