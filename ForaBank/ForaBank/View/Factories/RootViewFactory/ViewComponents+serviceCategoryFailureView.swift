//
//  ViewComponents+serviceCategoryFailureView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2024.
//

import SwiftUI

extension ViewComponents {
    
    // TODO: - consider grouping, incl. a separate factory(?)
    func serviceCategoryFailureView(
        binder: ServiceCategoryFailureDomain.Binder
    ) -> some View {
        
        ServiceCategoryFailureView(
            binder: binder,
            destinationView: destinationView
        )
    }
    
    @ViewBuilder
    private func destinationView(
        destination: ServiceCategoryFailureDomain.FlowDomain.State.Destination
    ) -> some View {
        
        switch destination {
        case let .detailPayment(paymentsViewModel):
            makePaymentsView(paymentsViewModel)
                .navigationBarHidden(true)
        }
    }
}
