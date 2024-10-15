//
//  MonolithicStore.swift
//
//
//  Created by Igor Malyarov on 15.10.2024.
//

public protocol MonolithicStore<Value> {
    
    associatedtype Value
    
    typealias InsertCompletion = (Result<Void, Error>) -> Void
    typealias RetrieveCompletion = (Value?) -> Void
    
    func insert(_: Value, _: @escaping InsertCompletion)
    func retrieve(_: @escaping RetrieveCompletion)
}
