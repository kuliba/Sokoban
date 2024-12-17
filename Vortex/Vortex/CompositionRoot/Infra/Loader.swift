//
//  Loader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2023.
//

import CVVPINServices
import Foundation

protocol Loader<Model> {
    
    associatedtype Model
    
    // MARK: - Load
    
    typealias LoadResult = Result<Model, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    
    func load(
        completion: @escaping LoadCompletion
    )
    
    // MARK: - Save
    
    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    
    func save(
        _ model: Model,
        validUntil: Date,
        completion: @escaping SaveCompletion
    )
}
