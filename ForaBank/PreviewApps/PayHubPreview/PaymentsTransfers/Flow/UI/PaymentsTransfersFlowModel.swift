//
//  PaymentsTransfersFlowModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import RxViewModel

typealias PaymentsTransfersFlowModel = RxViewModel<PaymentsTransfersFlowState<ProfileModel, QRModel>, PaymentsTransfersFlowEvent<ProfileModel, QRModel>, PaymentsTransfersFlowEffect>
