//
//  SessionCodeLoader.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

public protocol SessionCodeLoader {
    
    typealias Result = Swift.Result<SessionCode, Error>
    typealias LoadCompletion = (Result) -> Void
    
    func load(completion: @escaping LoadCompletion)
}
