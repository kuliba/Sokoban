//
//  ServiceSpy.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

typealias ServiceSpyOf<T> = ServiceSpy<T, Data>

typealias RemoteServiceSpy<Success, Failure, Request> = ServiceSpy<Result<Success, Failure>, Request> where Failure: Error
typealias RemoteServiceSpyOf<Success> = RemoteServiceSpy<Success, Error, Data>

final class ServiceSpy<T, Request> {

    typealias Completion = (T) -> Void
    typealias Message = (request: Request, completion: Completion)
    
    private var messages = [Message]()
    var callCount: Int { messages.count }
    
    func process(
        _ request: Request,
        completion: @escaping Completion
    ) {
        messages.append((request, completion))
    }
    
    func complete(
        with result: T,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
}
