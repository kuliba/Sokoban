//
//  Route.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct Route<ViewModel, Destination: Identifiable> {
    
    let viewModel: ViewModel
    var destination: Destination
}
