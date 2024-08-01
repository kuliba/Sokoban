//
//  AnywayTransactionEffectHandlerMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import RemoteServices

final class AnywayTransactionEffectHandlerMicroServicesComposer {
    
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
}

extension AnywayTransactionEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            getVerificationCode: getVerificationCode(_:),
            initiatePayment: initiatePayment(_:_:),
            makePayment: makePayment(_:_:),
            paymentEffectHandle: paymentEffectHandle(_:_:),
            processPayment: processPayment(_:_:)
        )
    }
}

extension AnywayTransactionEffectHandlerMicroServicesComposer {
    
    typealias NanoServices = AnywayTransactionEffectHandlerNanoServices
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
}

private extension AnywayTransactionEffectHandlerMicroServicesComposer {
    
    func getVerificationCode(
        _ completion: @escaping MicroServices.GetVerificationCodeCompletion
    ) {
        nanoServices.getVerificationCode(completion)
    }
    
    func initiatePayment(
        _ digest: AnywayPaymentDigest,
        _ completion: @escaping MicroServices.ProcessCompletion
    ) {
        nanoServices.initiatePayment(digest, completion)
    }
    
    func makePayment(
        _ code: VerificationCode,
        _ completion: @escaping MakePaymentCompletion
    ) {
        nanoServices.makeTransfer(code) { [weak self] in
            
            guard let self else { return }
            
            switch $0 {
            case let .failure(.otpFailure(message)):
                completion(.failure(.otpFailure(message)))
                
            case .failure(.terminal):
                completion(.failure(.terminal))
                
            case let .success(response):
                getDetails(response, completion)
            }
        }
    }
    
    typealias MakePaymentCompletion = MicroServices.MakePaymentCompletion
    
    private func getDetails(
        _ response: NanoServices.MakeTransferResponse,
        _ completion: @escaping MakePaymentCompletion
    ) {
        nanoServices.getDetails(response.detailID) { [weak self] in
            
            guard self != nil else { return }
            
            completion(.success(response.makeTransactionReport(with: $0)))
        }
    }
    
    func paymentEffectHandle(
        _ effect: AnywayPaymentEffect,
        _ dispatch: @escaping MicroServices.PaymentDispatch
    ) {
#warning("FIXME")
        fatalError()
    }
    
    func processPayment(
        _ digest: AnywayPaymentDigest,
        _ completion: @escaping MicroServices.ProcessCompletion
    ) {
        nanoServices.processPayment(digest, completion)
    }
}

private extension AnywayTransactionEffectHandlerNanoServices.MakeTransferResponse {
    
    func makeTransactionReport(
        with operationDetails: Response?
    ) -> AnywayTransactionReport {
        
        switch operationDetails {
        case .none:
            return .init(
                status: status,
                info: .detailID(detailID)
            )
            
        case let .some(operationDetails):
            return .init(
                status: status,
                info: .details(.init(
                    id: detailID,
                    response: operationDetails
                ))
            )
        }
    }
    
    typealias Response = RemoteServices.ResponseMapper.GetOperationDetailByPaymentIDResponse
}
