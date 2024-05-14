//
//  UtilityPaymentMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

final class UtilityPaymentMicroServicesComposer<LastPayment, Operator> {
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(
            initiateUtilityPayment: initiateUtilityPayment
        )
    }
}

extension UtilityPaymentMicroServicesComposer {
    
    typealias MicroServices = UtilityPaymentMicroServices<LastPayment, Operator>
    typealias NanoServices = UtilityPaymentNanoServices<LastPayment, Operator>
}

private extension UtilityPaymentMicroServicesComposer {
    
    func initiateUtilityPayment(
        completion: @escaping InitiateUtilityPaymentCompletion
    ) {
        #warning("FIXME")
        fatalError("unimplemented")
    }
    
    typealias InitiateUtilityPaymentCompletion = MicroServices.InitiateUtilityPaymentCompletion
}
