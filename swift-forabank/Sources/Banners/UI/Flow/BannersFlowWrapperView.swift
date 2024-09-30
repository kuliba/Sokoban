//
//  BannersFlowWrapperView.swift
//
//
//  Created by Andryusina Nataly on 11.09.2024.
//

import RxViewModel
import SwiftUI

public typealias BannersFlowWrapperView<FlowView> = RxWrapperView<FlowView, BannersFlowState, BannersFlowEvent, BannersFlowEffect> where FlowView: View
