//
//  PaymentsTransfersFlow.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import RxViewModel

typealias PaymentsTransfersFlowState = PayHub.PaymentsTransfersFlowState<ProfileModel, QRModel>
typealias PaymentsTransfersFlowEvent = PayHub.PaymentsTransfersFlowEvent<ProfileModel, QRModel>

typealias PaymentsTransfersFlowReducer = PayHub.PaymentsTransfersFlowReducer<ProfileModel, QRModel>
typealias PaymentsTransfersFlowEffectHandler = PayHub.PaymentsTransfersFlowEffectHandler<ProfileModel, QRModel>

typealias PaymentsTransfersFlow = RxViewModel<PaymentsTransfersFlowState, PaymentsTransfersFlowEvent, PaymentsTransfersFlowEffect>
