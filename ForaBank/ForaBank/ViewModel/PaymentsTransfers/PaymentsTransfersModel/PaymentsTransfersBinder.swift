//
//  PaymentsTransfersBinder.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.08.2024.
//

import PayHub

// MARK: - Content

typealias PaymentsTransfersContentModel = PaymentsTransfersModel<Void, OperationPickerBinder>

// MARK: - Flow

typealias PaymentsTransfersFlowModel = Void

// MARK: - Binder

typealias PaymentsTransfersBinder = PayHub.Holder<PaymentsTransfersContentModel, PaymentsTransfersFlowModel>
