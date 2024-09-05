//
//  PickerFlow.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import PayHub
import RxViewModel

public typealias PickerFlow<Element, Navigation> = RxViewModel<PickerFlowState<Navigation>, PickerFlowEvent<Element, Navigation>, PickerFlowEffect<Element>>
