//
//  RemoteServiceDecorator+handleFailure.swift
//
//
//  Created by Igor Malyarov on 10.01.2024.
//

public extension RemoteServiceDecorator {
    
    typealias HandleFailure = (ProcessError, @escaping () -> Void) -> Void
    
    convenience init(
        decoratee: Decoratee,
        handleFailure: @escaping HandleFailure
    ) {
        self.init(
            decoratee: decoratee,
            decoration: { result, completion in
                
                switch result {
                case let .failure(error):
                    handleFailure(error, completion)
                    
                case .success:
                    completion()
                }
            }
        )
    }
}
