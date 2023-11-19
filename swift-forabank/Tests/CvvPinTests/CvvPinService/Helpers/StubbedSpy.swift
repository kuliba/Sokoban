//
//  StubbedSpy.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

typealias StubbedSpyOf<Request, Success> = StubbedSpy<Request, Success, Error>

final class StubbedSpy<Request, Success, Failure: Error> {
    
    typealias Result = Swift.Result<Success, Error>
    
    private var stubbedResults: [Result]
    private(set) var messages = [Request]()
    
    init(stub: [Result]) {
   
        self.stubbedResults = stub
    }
    
    func make(
        _ request: Request
    ) throws -> Success {
        
        messages.append(request)
        return try stubbedResults.removeLast().get()
    }
}
