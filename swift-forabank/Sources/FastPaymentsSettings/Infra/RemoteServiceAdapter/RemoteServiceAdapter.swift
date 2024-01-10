//
//  RemoteServiceAdapter.swift
//
//
//  Created by Igor Malyarov on 10.01.2024.
//

public final class RemoteServiceAdapter<Input, OldOutput, Output, ProcessError>
where ProcessError: Error {
    
    private let service: Service
    private let adapt: Adapt
    
    public init(
        service: Service,
        adapt: @escaping Adapt
    ) {
        self.service = service
        self.adapt = adapt
    }
}

extension RemoteServiceAdapter: RemoteServiceInterface {
    
    public func process(
        _ input: Input,
        completion: @escaping ProcessCompletion
    ) {
        service.process(input) { [adapt] result in
            
            completion(result.map(adapt))
        }
    }
}

public extension RemoteServiceAdapter {
    
    typealias Service = any RemoteServiceInterface<Input, OldOutput, ProcessError>
    typealias Adapt = (OldOutput) -> Output
    
    typealias ProcessResult = Result<Output, ProcessError>
    typealias ProcessCompletion = (ProcessResult) -> Void
}
