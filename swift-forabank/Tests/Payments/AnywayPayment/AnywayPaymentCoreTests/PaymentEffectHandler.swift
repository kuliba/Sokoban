//
//  PaymentEffectHandler.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

final class PaymentEffectHandler<Digest, Update> {
    
    private let process: Process
    
    init(process: @escaping Process) {
        
        self.process = process
    }
}

extension PaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .continue(digest):
            process(digest, dispatch)
        }
    }
}

private extension PaymentEffectHandler {
    
    func process(
        _ digest: Digest,
        _ dispatch: @escaping Dispatch
    ) {
        process(digest) { [weak self] in
            
            guard self != nil else { return }
            
            switch $0 {
            case let .failure(serviceFailure):
                dispatch(.update(.failure(serviceFailure)))
                
            case let .success(update):
                dispatch(.update(.success(update)))
            }
        }
    }
}

extension PaymentEffectHandler {
    
    typealias ProcessResult = Result<Update, ServiceFailure>
    typealias ProcessCompletion = (ProcessResult) -> Void
    typealias Process = (Digest, @escaping ProcessCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PaymentEvent<Update>
    typealias Effect = PaymentEffect<Digest>
}
