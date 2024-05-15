//
//  UtilityPrepaymentNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.05.2024.
//

import Foundation
import OperatorsListComponents

final class UtilityPrepaymentNanoServicesComposer {
    
    private let model: Model
    private let flag: Flag
    
    init(
        model: Model,
        flag: Flag
    ) {
        self.model = model
        self.flag = flag
    }
}

extension UtilityPrepaymentNanoServicesComposer {
    
    func compose() -> NanoServices {
        
        .init(loadOperators: loadOperators)
    }
}

extension UtilityPrepaymentNanoServicesComposer {
    
    typealias Flag = StubbedFeatureFlag.Option
    
    typealias NanoServices = UtilityPrepaymentNanoServices<Operator>
    
    typealias Payload = LoadOperatorsPayload<String>
    typealias Operator = UtilityPaymentOperator
}

private extension UtilityPrepaymentNanoServicesComposer {
    
    func loadOperators(
        payload: Payload,
        completion: @escaping ([Operator]) -> Void
    ) {
        switch flag {
        case .live:
            model.loadOperators(payload, completion)
            
        case .stub:
            DispatchQueue.main.delay(for: .seconds(1)) { completion([]) }
        }
    }
}
