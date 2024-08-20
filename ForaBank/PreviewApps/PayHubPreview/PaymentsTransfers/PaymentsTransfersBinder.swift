//
//  PaymentsTransfersBinder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

final class PaymentsTransfersBinder<PayHub>
where PayHub: Loadable {
    
    let content: Content
    let flow: Flow
    
    init(
        content: Content,
        flow: Flow
    ) {
        self.content = content
        self.flow = flow
    }
}

extension PaymentsTransfersBinder {
    
    typealias Content = PaymentsTransfersModel<PayHub>
    typealias Flow = PaymentsTransfersFlowModel
}
