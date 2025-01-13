//
//  CacheSpy.swift
//  
//
//  Created by Igor Malyarov on 09.10.2023.
//

typealias CacheSpyOf<Model> = CacheSpy<Model, Error>

final class CacheSpy<Model, Failure: Error> {
    
    typealias Result = Swift.Result<Void, Failure>
    typealias Completion = (Result) -> Void
    typealias Message = (model: Model, completion: Completion)
    
    var callCount: Int { messages.count }
    private(set) var messages = [Message]()
    
    func save(
        _ model: Model,
        completion: @escaping Completion
    ) {
        messages.append((model, completion))
    }
    
    func complete(
        with result: Result,
        at index: Int = 0
    ) {
        messages[index].completion(result)
    }
}
