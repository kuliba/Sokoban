//
//  RemoteServiceInterface.swift
//  
//
//  Created by Igor Malyarov on 10.01.2024.
//

public protocol RemoteServiceInterface<Input, Output, ProcessError> {
    
    associatedtype Input
    associatedtype Output
    associatedtype ProcessError: Error
    
    typealias ProcessResult = Result<Output, ProcessError>
    typealias ProcessCompletion = (ProcessResult) -> Void
    
    func process(
        _ input: Input,
        completion: @escaping ProcessCompletion
    )
}
