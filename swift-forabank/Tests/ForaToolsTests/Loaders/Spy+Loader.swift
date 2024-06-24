//
//  Spy+Loader.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

extension Spy: Loader {
    
    func load(
        _ payload: Payload,
        _ completion: @escaping (Response) -> Void
    ) {
        process(payload, completion: completion)
    }
}
