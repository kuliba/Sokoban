//
//  RemoteServiceDecorator+handleSuccess.swift
//
//
//  Created by Igor Malyarov on 10.01.2024.
//

public extension RemoteServiceDecorator {
    
    typealias HandleSuccess = (Output, @escaping () -> Void) -> Void
    
    convenience init(
        decoratee: Decoratee,
        handleSuccess: @escaping HandleSuccess
    ) {
        self.init(
            decoratee: decoratee,
            decoration: { result, completion in
                
                switch result {
                case .failure:
                    completion()
                    
                case let .success(success):
                    handleSuccess(success, completion)
                }
            }
        )
    }
}
