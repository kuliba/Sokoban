//
//  LocalLoaderComposer.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.09.2024.
//

import CombineSchedulers
import Foundation

final class LocalLoaderComposer {
    
    private let agent: LocalAgentProtocol
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        agent: LocalAgentProtocol,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>,
        backgroundScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.agent = agent
        self.interactiveScheduler = interactiveScheduler
        self.backgroundScheduler = backgroundScheduler
    }
}

extension LocalLoaderComposer {
    
    typealias Load<T> = (@escaping (T?) -> Void) -> Void
    
    func composeLoad<T, Model: Decodable>(
        fromModel: @escaping (Model) -> T
    ) -> Load<T> {
        
        return { completion in
            
            self.interactiveScheduler.schedule {
                
                let model = self.agent.load(type: Model.self)
                completion(model.map(fromModel))
            }
        }
    }
}

extension LocalLoaderComposer {
    
    typealias Serial = String
    typealias Save<T> = (T, Serial, @escaping (Result<Void, Error>) -> Void) -> Void
    
    func composeSave<T, Model: Encodable>(
        toModel: @escaping (T) -> Model
    ) -> Save<T> {
        
        return { value, serial, completion in
            
            self.backgroundScheduler.schedule {
                
                do {
                    try self.agent.store(toModel(value), serial: serial)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}

extension LocalLoaderComposer {
    
    typealias Reduce<T> = (T, T) -> (T, Bool)
    typealias Update<T> = (T, Serial?, @escaping (Result<Void, Error>) -> Void) -> Void
    
    func composeUpdate<T, Model: Codable>(
        toModel: @escaping (T) -> Model,
        reduce: @escaping Reduce<Model>
    ) -> Update<T> {
        
        return { value, serial, completion in
            
            self.backgroundScheduler.schedule {
                
                do {
                    try self.agent.update(
                        with: toModel(value),
                        serial: serial,
                        using: reduce
                    )
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - update

extension LocalAgentProtocol {
    
    func update<T: Codable>(
        with newData: T,
        serial: String?,
        using reduce: (T, T) -> (T, Bool)
    ) throws {
        
        let lock = NSRecursiveLock()
        lock.lock()
        defer { lock.unlock() }
        
        guard let existing = try? load(type: T.self).get(orThrow: LocalAgentLoadError())
        else {
            return try store(newData, serial: serial)
        }
        
        let (updated, hasChanges) = reduce(existing, newData)
        
        if hasChanges {
            
            try store(updated, serial: serial)
        }
    }
}

struct LocalAgentLoadError: Error {}
