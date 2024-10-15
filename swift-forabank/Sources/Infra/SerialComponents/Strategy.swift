//
//  Strategy.swift
//
//
//  Created by Igor Malyarov on 15.10.2024.
//

/// A strategy that attempts to load data using a primary load function, with a fallback if the primary fails.
public final class Strategy<T> {
    
    /// The primary load function.
    @usableFromInline
    let primary: Load
    
    /// The fallback load function used if the primary fails.
    @usableFromInline
    let fallback: Load
    
    /// Initialises the strategy with a primary and a fallback load function.
    /// - Parameters:
    ///   - primary: The primary load function.
    ///   - fallback: The fallback load function.
    public init(
        primary: @escaping Load,
        fallback: @escaping Load
    ) {
        self.primary = primary
        self.fallback = fallback
    }
    
    /// Completion handler type for load operations.
    public typealias LoadCompletion = ([T]?) -> Void
    /// Type representing a load function.
    public typealias Load = (@escaping LoadCompletion) -> Void
}

public extension Strategy {
    
    /// Attempts to load data using the primary load function, falling back to the fallback function if necessary.
    /// - Parameter completion: A closure called with the loaded data or `nil`.
    @inlinable
    func load(
        completion: @escaping LoadCompletion
    ) {
        primary { [fallback] in
            
            switch $0 {
            case .none:
                fallback { completion($0) }
                
            case let .some(value):
                completion(value)
            }
        }
    }
}
