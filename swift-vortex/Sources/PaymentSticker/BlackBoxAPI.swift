//
//  BlackBoxAPI.swift
//
//
//  Created by Дмитрий Савушкин on 13.12.2023.
//

import Foundation

public enum BlackBoxAPI {}

public extension BlackBoxAPI {
    
    typealias Request = (Operation, Event)
    typealias Success = OperationStateViewModel.State
    typealias Result = Swift.Result<Success, Error>
    typealias Completion = (Result) -> Void
    typealias AsyncGet = (Request, @escaping Completion) -> Void
}
