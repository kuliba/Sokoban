//
//  PaymentsViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct PaymentsViewFactory<DestinationView>
where DestinationView: View {
    
    let makeDestinationView: MakeDestinationView
}

extension PaymentsViewFactory {
    
    typealias Destination = PaymentsState.Destination
    typealias MakeDestinationView = (Destination) -> DestinationView
}
