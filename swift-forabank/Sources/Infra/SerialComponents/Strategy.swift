//
//  Strategy.swift
//
//
//  Created by Igor Malyarov on 15.10.2024.
//

public final class Strategy<T> {
    
    @usableFromInline
    let primary: Load
    
    @usableFromInline
    let fallback: Load
    
    public init(
        primary: @escaping Load,
        fallback: @escaping Load
    ) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public typealias LoadCompletion = ([T]?) -> Void
    public typealias Load = (@escaping LoadCompletion) -> Void
}

public extension Strategy {
    
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
