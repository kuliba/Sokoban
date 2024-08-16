//
//  PaymentsTransfersViewFactory.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import SwiftUI

struct PaymentsTransfersViewFactory<PayHub, PayHubView> {
    
    let makePayHubView: MakePayHubView
}

extension PaymentsTransfersViewFactory {
    
    typealias MakePayHubView = (PayHub) -> PayHubView
}
