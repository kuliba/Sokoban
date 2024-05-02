//
//  PaymentViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct PaymentViewFactory<UtilityPrepaymentView>
where UtilityPrepaymentView: View {
    
    let makeUtilityPrepaymentView: MakeUtilityPrepaymentView
}

extension PaymentViewFactory {
    
    typealias MakeUtilityPrepaymentView = (UtilityServicePrepaymentState) -> UtilityPrepaymentView
}
