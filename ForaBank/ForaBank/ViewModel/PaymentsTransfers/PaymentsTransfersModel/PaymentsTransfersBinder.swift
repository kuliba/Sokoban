//
//  PaymentsTransfersBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.08.2024.
//

import PayHub

// MARK: - Content

typealias PaymentsTransfersContentModel = PaymentsTransfersModel<PayHubPickerBinder>

// MARK: - Flow

typealias PaymentsTransfersFlowModel = Void

// MARK: - Binder

typealias PaymentsTransfersBinder = PayHub.Binder<PaymentsTransfersContentModel, PaymentsTransfersFlowModel>
