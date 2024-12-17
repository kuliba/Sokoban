//
//  LoaderSpy.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import Foundation

final class LoaderSpy<Value>: Loader {
    
    typealias Model = Value

    private(set) var messages = [Message]()
    
    var callCount: Int { messages.count }
    
    private var loadCompletions = [LoadCompletion]()
    private var saveCompletions = [SaveCompletion]()
    
    func load(
        completion: @escaping LoadCompletion
    ) {
        messages.append(.load)
        loadCompletions.append(completion)
    }
    
    func completeLoad(
        with result: Result<Value, Error>,
        at index: Int = 0
    ) {
        loadCompletions[index](result)
    }
    
    func save(
        _ model: Value,
        validUntil: Date,
        completion: @escaping SaveCompletion
    ) {
        messages.append(.save(model, validUntil: validUntil))
        saveCompletions.append(completion)
    }

    func completeSave(
        with result: Result<Void, Error>,
        at index: Int = 0
    ) {
        saveCompletions[index](result)
    }
    
    enum Message {
        
        case load
        case save(Value, validUntil: Date)
    }
}

extension LoaderSpy.Message: Equatable where Value: Equatable {}
