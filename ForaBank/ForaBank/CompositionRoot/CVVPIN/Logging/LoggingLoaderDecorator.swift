//
//  LoggingLoaderDecorator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import Foundation

final class LoggingLoaderDecorator<T> {
    
    typealias Log = (LoggerAgentLevel, String, StaticString, UInt) -> Void
    
    private let decoratee: any Loader<T>
    private let log: Log
    
    init(
        decoratee: any Loader<T>,
        log: @escaping Log
    ) {
        self.decoratee = decoratee
        self.log = log
    }
}

extension LoggingLoaderDecorator: Loader {
    typealias Model = T
    
    func load(
        completion: @escaping LoadCompletion
    ) {
        decoratee.load { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log(.error, "\(String(describing: self)): Load failure: \(error).", #file, #line)
                
            case let .success(model):
                log(.info, "\(String(describing: self)): Load success: \(model).", #file, #line)
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
        ) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                log(.error, "\(String(describing: self)): Save failure: \(error).", #file, #line)
                
            case .success:
                log(.info, "\(String(describing: self)): Save success.", #file, #line)
            }
            
            completion(result)
        }
    }
}
