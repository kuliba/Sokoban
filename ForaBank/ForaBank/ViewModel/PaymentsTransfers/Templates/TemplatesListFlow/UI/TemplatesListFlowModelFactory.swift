//
//  TemplatesListFlowModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.08.2024.
//

import Foundation

struct TemplatesListFlowModelFactory {
    
    let makePaymentModel: MakePaymentModel
}

extension TemplatesListFlowModelFactory {
    
    typealias MakePaymentModel = (PaymentTemplateData, @escaping () -> Void) -> PaymentsViewModel
}
