//
//  PaymentsTransfersFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import RxViewModel

public typealias PaymentsTransfersFlowState = PayHub.PaymentsTransfersFlowState<ProfileModel, QRModel>
public typealias PaymentsTransfersFlowNavigation = PayHub.PaymentsTransfersFlowNavigation<ProfileModel, QRModel>
typealias PaymentsTransfersFlowEvent = PayHub.PaymentsTransfersFlowEvent<ProfileModel, QRModel>

typealias PaymentsTransfersFlowReducer = PayHub.PaymentsTransfersFlowReducer<ProfileModel, QRModel>
typealias PaymentsTransfersFlowEffectHandler = PayHub.PaymentsTransfersFlowEffectHandler<ProfileModel, QRModel>

typealias PaymentsTransfersFlowModel = RxViewModel<PaymentsTransfersFlowState, PaymentsTransfersFlowEvent, PaymentsTransfersFlowEffect>
