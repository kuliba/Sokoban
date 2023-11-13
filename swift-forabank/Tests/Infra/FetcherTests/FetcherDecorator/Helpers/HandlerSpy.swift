//
//  HandlerSpy.swift
//  
//
//  Created by Igor Malyarov on 09.11.2023.
//

final class HandlerSpy<Success, Failure: Error> {
    
    typealias Completion = () -> Void
    typealias SuccessMessage = (success: Success, completion: Completion)
    typealias FailureMessage = (failure: Failure, completion: Completion)
    
    private(set) var successMessages = [SuccessMessage]()
    private(set) var failureMessages = [FailureMessage]()
    
    var handledSuccessCount: Int { successMessages.count }
    var handledFailureCount: Int { failureMessages.count }
    
    func handleSuccess(
        _ success: Success,
        _ completion: @escaping Completion
    ) {
        successMessages.append((success, completion))
    }
    
    func completeSuccess(at index: Int = 0) {
        
        successMessages[index].completion()
    }
    
    func handleFailure(
        _ failure: Failure,
        _ completion: @escaping Completion
    ) {
        failureMessages.append((failure, completion))
    }
    
    func completeFailure(at index: Int = 0) {
        
        failureMessages[index].completion()
    }
}
