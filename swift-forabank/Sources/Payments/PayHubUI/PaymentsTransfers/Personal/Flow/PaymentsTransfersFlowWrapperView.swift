//
//  PaymentsTransfersFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PaymentsTransfersFlowWrapperView<FlowView> = RxWrapperView<FlowView, PaymentsTransfersPersonalFlowState, PaymentsTransfersPersonalFlowEvent, PaymentsTransfersPersonalFlowEffect> where FlowView: View
