//
//  AnyLoader+mapError.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

public extension AnyLoader {
    
    /// Creates a new instance of `AnyLoader` with the error type mapped using the provided closure.
    ///
    /// - Parameter mapError: A closure that maps the current error type to a new error type.
    /// - Returns: A new `AnyLoader` with the error type mapped.
    func mapError<Success, Failure, NewFailure>(
        _ mapError: @escaping (Failure) -> NewFailure
    ) -> AnyLoader<Payload, Result<Success, NewFailure>>
    where Response == Result<Success, Failure> {
        
        AnyLoader<Payload, Result<Success, NewFailure>> { payload, completion in
            
            self.load(payload) { result in
                switch result {
                case let .success(response):
                    completion(.success(response))
                    
                case let .failure(error):
                    completion(.failure(mapError(error)))
                }
            }
        }
    }
}
