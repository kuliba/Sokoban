//
//  Loader.swift
//  
//
//  Created by Igor Malyarov on 06.10.2023.
//

import Foundation

public final class Loader<Model, Local> {
    
    public typealias ToModel = (Local) -> Model
    public typealias ToLocal = (Model) -> Local
    public typealias CurrentDate = () -> Date
    
    private let store: any Store<Local>
    private let toModel: ToModel
    private let toLocal: ToLocal
    private let currentDate: CurrentDate
    
    public init(
        store: any Store<Local>,
        toModel: @escaping ToModel,
        toLocal: @escaping ToLocal,
        currentDate: @escaping CurrentDate = Date.init
    ) {
        self.store = store
        self.toModel = toModel
        self.toLocal = toLocal
        self.currentDate = currentDate
    }
}

// MARK: - Load

public extension Loader {
    
    typealias LoadResult = Result<Model, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    
    func load(
        completion: @escaping LoadCompletion
    ) {
        store.retrieve { [weak self] result in
            
            guard let self else { return }
            
            completion(.init {
                
                let (local, validUntil) = try result.get()
                try self.validate(validUntil)
                return self.toModel(local)
            })
        }
    }
    
    private func validate(_ validUntil: Date) throws {
        
        let current = currentDate()
        
        guard validUntil >= current
        else {
            throw LoadError.invalidCache(validatedAt: current, validUntil: validUntil)
        }
    }
    
    enum LoadError: Error {
        
        case invalidCache(validatedAt: Date, validUntil: Date)
    }
}

// MARK: - Save

public extension Loader {
    
    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    
    func save(
        _ model: Model,
        validUntil: Date,
        completion: @escaping SaveCompletion
    ) {
        store.deleteCache { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case .success:
                store.insert(
                    toLocal(model),
                    validUntil: validUntil
                ) { [weak self] in
                    
                    guard self != nil else { return }
                    
                    completion($0)
                }
            }
        }
    }
}
