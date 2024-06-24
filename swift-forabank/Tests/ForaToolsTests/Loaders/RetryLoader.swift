//
//  RetryLoader.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

final class RetryLoader<Payload, Response, Failure>
where Failure: Error {
    
    private let performer: any Performer
    
    init(
        performer: any Performer
    ) {
        self.performer = performer
    }
    
    typealias Performer = Loader<Payload, LoadResult>
    typealias LoadResult = Result<Response, Failure>
}

extension RetryLoader: Loader {
    
    func load(
        _ payload: Payload,
        _ completion: @escaping (LoadResult) -> Void
    ) {
        performer.load(payload) {
            
            switch $0 {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                completion(.success(response))
            }
        }
    }
}
