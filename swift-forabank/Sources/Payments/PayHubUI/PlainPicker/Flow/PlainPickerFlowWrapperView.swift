//
//  PlainPickerFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PlainPickerFlowWrapperView<ContentView, Element, Navigation> = RxWrapperView<ContentView, PickerFlowState<Navigation>, PickerFlowEvent<Element, Navigation>, PickerFlowEffect<Element>> where ContentView: View
