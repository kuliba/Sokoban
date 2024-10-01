//
//  LocalAgentAsyncWrapper.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.09.2024.
//

import CombineSchedulers
import Foundation

/// A wrapper around `LocalAgentProtocol` that provides asynchronous scheduling
/// for loading, saving, and updating operations.
final class LocalAgentAsyncWrapper {

    private let agent: LocalAgentProtocol
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    private let backgroundScheduler: AnySchedulerOf<DispatchQueue>

    /// Initialises the wrapper with the provided local agent and schedulers.
    ///
    /// - Parameters:
    ///   - agent: The local agent handling data operations.
    ///   - interactiveScheduler: The scheduler for tasks needing user interaction.
    ///   - backgroundScheduler: The scheduler for background operations.
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

extension LocalAgentAsyncWrapper {

    /// A type alias for an asynchronous load operation.
    typealias Load<T> = (@escaping (T?) -> Void) -> Void

    /// Composes an asynchronous load operation.
    ///
    /// - Parameter fromModel: A closure to map the decoded model to the desired type.
    /// - Returns: A `Load` function that executes the loading operation on the interactive scheduler.
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

extension LocalAgentAsyncWrapper {

    /// A type alias for an asynchronous save operation.
    typealias Serial = String
    typealias Save<T> = (T, Serial, @escaping (Result<Void, Error>) -> Void) -> Void

    /// Composes an asynchronous save operation.
    ///
    /// - Parameter toModel: A closure to map the value to the model type.
    /// - Returns: A `Save` function that stores the value asynchronously on the background scheduler.
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

extension LocalAgentAsyncWrapper {
    
    /// A type alias for reducing two values into one and returning if there were changes.
    typealias Reduce<T> = (T, T) -> (T, Bool)
    
    /// A type alias for an asynchronous update operation.
    typealias Update<T> = (T, Serial?, @escaping (Result<Void, Error>) -> Void) -> Void
    
    /// Composes an asynchronous update operation.
    ///
    /// - Parameters:
    ///   - toModel: A closure to map the value to the model type.
    ///   - reduce: A closure to reduce the existing model and new data.
    /// - Returns: An `Update` function that updates the value asynchronously on the background scheduler.
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
