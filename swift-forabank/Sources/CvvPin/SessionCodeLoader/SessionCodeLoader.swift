//
//  SessionCodeLoader.swift
//  
//
//  Created by Igor Malyarov on 13.07.2023.
//

public protocol SessionCodeLoader {
    
    typealias Result = GetProcessingSessionCodeDomain.Result
    typealias LoadCompletion = GetProcessingSessionCodeDomain.Completion
    
    func load(completion: @escaping LoadCompletion)
}
