//
//  PaymentsTransfersToolbarContentWrapperView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PaymentsTransfersToolbarContentWrapperView<ContentView> = RxWrapperView<ContentView, PaymentsTransfersToolbarState, PaymentsTransfersToolbarEvent, PaymentsTransfersToolbarEffect> where ContentView: View
