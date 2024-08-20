//
//  PaymentsTransfersBinder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

import PayHub

typealias PaymentsTransfersContent = PaymentsTransfersModel<PayHubPickerBinder>

typealias PaymentsTransfersBinder = PayHub.Binder<PaymentsTransfersModel<PayHubPickerBinder>, PaymentsTransfersFlowModel>
