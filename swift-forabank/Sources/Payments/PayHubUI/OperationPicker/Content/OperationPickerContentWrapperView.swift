//
//  OperationPickerContentWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias OperationPickerContentWrapperView<ContentView, Latest> = RxWrapperView<ContentView, OperationPickerState<Latest>, OperationPickerEvent<Latest>, OperationPickerEffect> where ContentView: View
