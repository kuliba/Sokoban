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
        
        if let payload,
           let index = Int(payload.0) {
            
            let i = (index + 1) / payload.1
            completion(.success(.page(pageNumber: i, pageSize: payload.1)))
            
        } else {
            
            completion(.success(.page(pageSize: payload?.1 ?? 20)))
        }
    }
}

public enum ServiceFailure: Error, Equatable {
    
    case connectivityError
    case serverError(String)
}
