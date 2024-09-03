//
//  PaymentsTransfersToolbarFlow.swift
//  
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import RxViewModel

public typealias PaymentsTransfersToolbarFlow<Profile, QR> = RxViewModel<PaymentsTransfersToolbarFlowState<Profile, QR>, PaymentsTransfersToolbarFlowEvent<Profile, QR>, PaymentsTransfersToolbarFlowEffect>
