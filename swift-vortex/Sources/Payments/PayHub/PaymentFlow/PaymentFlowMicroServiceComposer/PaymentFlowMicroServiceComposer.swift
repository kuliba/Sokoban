//
//  PaymentFlowMicroServiceComposer.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public final class PaymentFlowMicroServiceComposer<Mobile, QR, Standard, Tax, Transport, Failure: Error> {
    
    private let nanoServices: NanoServices
    
    public init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    public typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<Mobile, QR, Standard, Tax, Transport, Failure>
}

public extension PaymentFlowMicroServiceComposer {
    
    func compose() -> MicroService {
        
        return .init(makePaymentFlow: makePaymentFlow)
    }
    
    typealias MicroService = PaymentFlowMicroService<Mobile, QR, Standard, Tax, Transport, Failure>
}

private extension PaymentFlowMicroServiceComposer {
    
    typealias Flow = MicroService.Flow
    
    func makePaymentFlow(
        type: PaymentFlowID,
        completion: @escaping (Result<MicroService.Flow, Failure>) -> Void
    ) {
        switch type {
        case .mobile:
            nanoServices.makeMobile {
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(mobile):
                    completion(.success(.mobile(mobile)))
                }
            }
            
        case .qr:
            nanoServices.makeQR {
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(qr):
                    completion(.success(.qr(qr)))
                }
            }
            
        case .standard:
            nanoServices.makeStandard {
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(standard):
                    completion(.success(.standard(standard)))
                }
            }
            
        case .taxAndStateServices:
            nanoServices.makeTax {
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(tax):
                    completion(.success(.taxAndStateServices(tax)))
                }
            }
            
        case .transport:
            nanoServices.makeTransport {
                
                switch $0 {
                case let .failure(failure):
                    completion(.failure(failure))
                    
                case let .success(transport):
                    completion(.success(.transport(transport)))
                }
            }
        }
    }
}
