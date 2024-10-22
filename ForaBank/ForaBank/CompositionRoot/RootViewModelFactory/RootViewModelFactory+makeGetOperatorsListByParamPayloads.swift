//
//  RootViewModelFactory+makeGetOperatorsListByParamPayloads.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

extension RootViewModelFactory {
    
    func makeGetOperatorsListByParamPayloads(
        from categories: [ServiceCategory]
    ) -> [RequestFactory.GetOperatorsListByParamPayload] {
        
        let serial = self.model.localAgent.serial(
            for: [CodableServicePaymentOperator].self
        )
        
        return categories
            .filter { $0.paymentFlow == .standard }
            .uniqueValues(by: \.name, useLast: false)
            .map { .init(serial: serial, category: $0) }
    }
}
