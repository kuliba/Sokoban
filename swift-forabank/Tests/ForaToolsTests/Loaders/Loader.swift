//
//  Loader.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

protocol Loader<Payload, Response> {
    
    associatedtype Payload
    associatedtype Response
    
    func load(
        _ payload: Payload,
        _ completion: @escaping (Response) -> Void
    )
}

extension Loader where Payload == Void {
    
    func load(
        _ completion: @escaping (Response) -> Void
    ) {
        load((), completion)
    }
}
