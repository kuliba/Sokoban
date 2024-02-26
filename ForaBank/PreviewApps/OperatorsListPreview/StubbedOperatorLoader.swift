//
//  StubbedOperatorLoader.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import Foundation
import OperatorsListComponents

final class StubbedOperatorLoader {
    
    typealias Payload = (Operator.ID, Int)
    typealias LoadResult = Result<[Operator], ServiceFailure>
    typealias LoadCompletion = (LoadResult) -> Void
    
    func load(
    _ payload: Payload?,
    _ completion: @escaping LoadCompletion
    ) {
        
        if payload != nil {
         
            completion(.success(.next1()))
            
        } else {
            
            completion(.success(.initial()))
        }
    }
}

public enum ServiceFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
