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
    
    typealias Save<T> = (SerialStamped<T>, @escaping (Result<Void, Error>) -> Void) -> Void
    
    func composeSave<T, Model: Encodable>(
        toModel: @escaping (T) -> Model
    ) -> Save<T> {
        
        return { stamped, completion in
            
            self.backgroundScheduler.schedule {
                
                do {
                    try self.agent.store(
                        toModel(stamped.value),
                        serial: stamped.serial
                    )
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
