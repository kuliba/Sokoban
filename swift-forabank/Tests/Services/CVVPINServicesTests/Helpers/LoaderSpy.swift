//
//  LoaderSpy.swift
//  
//
//  Created by Igor Malyarov on 08.10.2023.
//

typealias LoaderSpyOf<Success> = LoaderSpy<Success, Error>

final class LoaderSpy<Success, Failure: Error> {
    
    typealias Result = Swift.Result<Success, Failure>
    typealias Completion = (Result) -> Void
    
    var callCount: Int { completions.count }
    private var completions = [Completion]()
    
    func load(completion: @escaping Completion) {
        
        completions.append(completion)
    }
    
    func complete(
        with result: Result,
        at index: Int = 0
    ) {
        completions[index](result)
    }
}
