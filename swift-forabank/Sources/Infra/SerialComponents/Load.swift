//
//  Load.swift
//  
//
//  Created by Igor Malyarov on 15.10.2024.
//

public typealias LoadCompletion<T> = ([T]?) -> Void
public typealias Load<T> = (@escaping LoadCompletion<T>) -> Void
