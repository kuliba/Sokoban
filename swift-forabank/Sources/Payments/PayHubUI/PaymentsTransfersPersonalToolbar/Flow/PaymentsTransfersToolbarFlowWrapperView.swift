//
//  PaymentsTransfersToolbarFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PaymentsTransfersToolbarFlowWrapperView<FlowView, Profile, QR> = RxWrapperView<FlowView, PaymentsTransfersToolbarFlowState<Profile, QR>, PaymentsTransfersToolbarFlowEvent<Profile, QR>, PaymentsTransfersToolbarFlowEffect> where FlowView: View
