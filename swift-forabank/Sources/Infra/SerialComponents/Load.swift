//
//  Load.swift
//  
//
//  Created by Igor Malyarov on 15.10.2024.
//

/// A closure type that handles the completion of a load operation, providing an optional array of loaded items.
public typealias LoadCompletion<T> = ([T]?) -> Void

/// A closure type representing a load operation, which takes a `LoadCompletion` closure as a parameter to handle the loaded items.
public typealias Load<T> = (@escaping LoadCompletion<T>) -> Void
