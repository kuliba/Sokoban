//
//  LoggingLoaderDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import Foundation

final class LoggingLoaderDecorator<T> {
    
    private let decoratee: any Loader<T>
    private let log: (String) -> Void
    
    init(
        decoratee: any Loader<T>,
        log: @escaping (String, StaticString, UInt) -> Void
    ) {
        self.decoratee = decoratee
        self.log = { log($0, #file, #line) }
    }
}

extension LoggingLoaderDecorator: Loader {
    typealias Model = T
    
    func load(
        completion: @escaping LoadCompletion
    ) {
        decoratee.load { [log] result in
            
            switch result {
            case let .failure(error):
                log("\(String(describing: self)): load failure: \(error).")
                
            case let .success(model):
                log("\(String(describing: self)): load success: \(model).")
            }
            
            completion(result)
        }
    }
    
    func save(
        _ model: T,
        validUntil: Date,
        completion: @escaping SaveCompletion
    ) {
        decoratee.save(
            model,
            validUntil: validUntil
        ) { [log] result in
        
            switch result {
            case let .failure(error):
                log("\(String(describing: self)): save failure: \(error).")
                
            case .success:
                log("\(String(describing: self)): save success.")
            }
            
            completion(result)
        }
    }
}
