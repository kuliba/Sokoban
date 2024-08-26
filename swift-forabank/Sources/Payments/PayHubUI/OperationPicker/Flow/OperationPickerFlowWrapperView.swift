//
//  OperationPickerFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias OperationPickerFlowWrapperView<ContentView, Exchange, Latest, LatestFlow, Status, Templates> = RxWrapperView<ContentView, OperationPickerFlowState<Exchange, LatestFlow, Status, Templates>, OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>, OperationPickerFlowEffect<Latest>> where ContentView: View
