//
//  PlainPickerFlowWrapperView.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PlainPickerFlowWrapperView<ContentView, Element, Navigation> = RxWrapperView<ContentView, PlainPickerFlowState<Navigation>, PlainPickerFlowEvent<Element, Navigation>, PlainPickerFlowEffect<Element>> where ContentView: View
