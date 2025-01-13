//
//  LoadNanoServices.swift
//
//
//  Created by Igor Malyarov on 07.01.2025.
//

/// `LoadNanoServices` provides a mechanism to load "latest" and "operators" data
/// for a given category asynchronously. It handles error scenarios and ensures
/// results are only delivered when valid operators are available.
public final class LoadNanoServices<Category, Latest, Operator> {
    
    /// Callback for loading the latest items.
    let loadLatest: LoadLatest
    
    /// Callback for loading operators.
    let loadOperators: LoadOperators
    
    /// Initializes with the required loaders.
    public init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
    }
}

public extension LoadNanoServices {
    
    /// Completion handler for loading latest items.
    typealias LoadLatestCompletion = (Result<[Latest], Error>) -> Void
    
    /// Function type for loading latest items for a given category.
    typealias LoadLatest = (Category, @escaping LoadLatestCompletion) -> Void
    
    /// Completion handler for loading operators.
    typealias LoadOperatorsCompletion = (Result<[Operator], Error>) -> Void
    
    /// Function type for loading operators for a given category.
    typealias LoadOperators = (Category, @escaping LoadOperatorsCompletion) -> Void
}

extension LoadNanoServices {
    
    /// Represents a successful result containing latest items and operators.
    public struct Success {
        
        /// Non-empty list of latest items.
        public let latest: [Latest]
        
        /// Non-empty list of operators.
        // TODO: enforce non-empty
        public let operators: [Operator]
        
        public init(
            latest: [Latest],
            operators: [Operator]
        ) {
            self.latest = latest
            self.operators = operators
        }
    }
}

public extension LoadNanoServices {
        
    /// Completion handler for the combined loading process.
    typealias LoadCompletion = (Success?) -> Void
    
    /// Executes the combined loading process for a given category.
    /// - Calls `loadOperators` first and validates results before calling `loadLatest`.
    /// - Delivers `nil` if operators fail to load or are empty.
    /// - Provides a `Success` object on valid results.
    func load(
        category: Category,
        completion: @escaping LoadCompletion
    ) {
        loadOperators(category) { [weak self] in
            
            guard let self else { return }
            
            guard case let .success(operators) = $0,
                  !operators.isEmpty
            else { return completion(nil) }
            
            loadLatest(category) { [weak self] in
                
                guard self != nil else { return }
                
                completion(.init(
                    latest: (try? $0.get()) ?? [],
                    operators: operators
                ))
            }
        }
    }
}

extension LoadNanoServices.Success: Equatable where Latest: Equatable, Operator: Equatable {}
