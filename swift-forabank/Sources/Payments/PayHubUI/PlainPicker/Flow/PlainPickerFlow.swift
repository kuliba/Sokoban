//
//  PlainPickerContent.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import RxViewModel

public typealias PlainPickerFlow<Element, Navigation> = RxViewModel<PlainPickerFlowState<Navigation>, PlainPickerFlowEvent<Element, Navigation>, PlainPickerFlowEffect<Element>>
