//
//  PaymentsTransfersPersonalToolbarContentWrapperView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import RxViewModel
import SwiftUI

public typealias PaymentsTransfersPersonalToolbarContentWrapperView<ContentView> = RxWrapperView<ContentView, PaymentsTransfersPersonalToolbarState, PaymentsTransfersPersonalToolbarEvent, PaymentsTransfersPersonalToolbarEffect> where ContentView: View
