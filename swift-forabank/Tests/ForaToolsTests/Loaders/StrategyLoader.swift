//
//  StrategyLoader.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

/// A class that attempts to load data using a primary loader and falls back to a secondary loader if the primary fails.
final class StrategyLoader<Payload, Response, Failure>
where Failure: Error {
    
    private let primary: any Primary
    private let secondary: any Secondary
    
    /// Initialises a new instance of `StrategyLoader`.
    ///
    /// - Parameters:
    ///   - primary: The primary loader.
    ///   - secondary: The secondary loader.
    init(
        primary: any Primary,
        secondary: any Secondary
    ) {
        self.primary = primary
        self.secondary = secondary
    }
    
    typealias Primary = Loader<Payload, LoadResult>
    typealias Secondary = Loader<Payload, LoadResult>
    typealias LoadResult = Result<Response, Failure>
}

extension StrategyLoader: Loader {
    
    /// Loads the specified payload using the primary loader. If the primary loader fails, it falls back to the secondary loader.
    ///
    /// - Parameters:
    ///   - payload: The payload to be loaded.
    ///   - completion: The completion handler to be called with the result of the loading operation.
    func load(
        _ payload: Payload,
        _ completion: @escaping (LoadResult) -> Void
    ) {
        primary.load(payload) { [weak self] in
            
            switch $0 {
            case .failure:
                self?.secondary.load(payload, completion)
                
            case let .success(response):
                completion(.success(response))
            }
        }
    }
}
