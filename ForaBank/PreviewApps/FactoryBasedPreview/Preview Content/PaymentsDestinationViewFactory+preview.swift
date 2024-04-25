//
//  PaymentsDestinationViewFactory+preview.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

extension PaymentsDestinationViewFactory
where UtilityPrepaymentView == FactoryBasedPreview.UtilityPrepaymentView {
    
    static let preview: Self = .init(
        makeUtilityPrepaymentView: UtilityPrepaymentView.init
    )
}
