//
//  PaymentsTransfersCorporateFlowWrapperView.swift
//
//
//  Created by Andryusina Nataly on 12.09.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PaymentsTransfersCorporateFlowWrapperView<FlowView> = RxWrapperView<FlowView, PaymentsTransfersCorporateFlowState, PaymentsTransfersCorporateFlowEvent, PaymentsTransfersCorporateFlowEffect> where FlowView: View
