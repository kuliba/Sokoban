//
//  MapPayloadDecorator.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

public final class MapPayloadDecorator<Payload, NewPayload, Response> {
    
    private let decoratee: Decoratee
    private let mapPayload: MapPayload
    
    public init(
        decoratee: @escaping Decoratee,
        mapPayload: @escaping (Payload) -> NewPayload
    ) {
        self.decoratee = decoratee
        self.mapPayload = mapPayload
    }
}

public extension MapPayloadDecorator {
    
    func callAsFunction(
        _ payload: Payload,
        completion: @escaping DecorateeCompletion
    ) {
        decoratee(mapPayload(payload)) { [weak self] in
            
            guard self != nil else { return }
            
            completion($0)
        }
    }
}

public extension MapPayloadDecorator {
    
    typealias DecorateeCompletion = (Response) -> Void
    typealias Decoratee = (NewPayload, @escaping DecorateeCompletion) -> Void
    typealias MapPayload = (Payload) -> NewPayload
}
