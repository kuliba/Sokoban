//
//  OptionalFetcher.swift
//
//
//  Created by Igor Malyarov on 18.12.2024.
//

public protocol OptionalFetcher<Payload, T> {
    
    associatedtype Payload
    associatedtype T
    
    func fetch(
        _ payload: Payload,
        completion: @escaping (T?) -> Void
    )
}
