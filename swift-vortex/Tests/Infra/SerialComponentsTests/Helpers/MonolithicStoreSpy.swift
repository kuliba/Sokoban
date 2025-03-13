//
//  MonolithicStoreSpy.swift
//
//
//  Created by Igor Malyarov on 10.03.2025.
//

import SerialComponents

final class MonolithicStoreSpy<Value>: MonolithicStore {
    
    private(set) var insertMessages = [InsertMessage]()
    private(set) var retrieveMessages = [RetrieveCompletion]()

    var insertedValues: [Value] {
        
        insertMessages.map(\.value)
    }
    
    func insert(
        _ value: Value,
        _ completion: @escaping InsertCompletion
    ) {
        insertMessages.append((value, completion))
    }
    
    func retrieve(
        _ completion: @escaping (Value?) -> Void // RetrieveCompletion
    ) {
        retrieveMessages.append(completion)
    }
    
    func completeInsert(
        with result: Result<Void, Error>,
        at index: Int = 0
    ) {
        insertMessages[index].completion(result)
    }
    
    func completeInsertWithError(
        _ error: Error = anyError(),
        at index: Int = 0
    ) {
        insertMessages[index].completion(.failure(error))
    }
    
    func completeInsertSuccessfully(
        at index: Int = 0
    ) {
        insertMessages[index].completion(.success(()))
    }
    
    func completeRetrieve(
        with value: Value?,
        at index: Int = 0
    ) {
        retrieveMessages[index](value)
    }
    
    typealias InsertMessage = (value: Value, completion: InsertCompletion)
}
