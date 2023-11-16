//
//  GetProcessingSessionCodeService.swift
//  
//
//  Created by Igor Malyarov on 19.10.2023.
//

public final class GetProcessingSessionCodeService<APIError>
where APIError: Error {
    
    public typealias ServiceDomain = RemoteServiceDomain<Void, GetProcessingSessionCodeResponse, APIError>
    public typealias Process = ServiceDomain.AsyncGet
    
    private let process: Process
    
    public init(process: @escaping Process) {
        
        self.process = process
    }
}

public extension GetProcessingSessionCodeService {
    
    typealias Result = Swift.Result<GetProcessingSessionCodeResponse, APIError>
    typealias Completion = (Result) -> Void
    
    func getCode(
        completion: @escaping Completion
    ) {
        process(()) { [weak self] result in
            
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

