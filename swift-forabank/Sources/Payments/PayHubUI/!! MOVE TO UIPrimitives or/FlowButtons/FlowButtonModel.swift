//
//  FlowButtonModel.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import PayHub
import RxViewModel

public typealias FlowButtonModel<Destination> = RxViewModel<FlowButtonState<Destination>, FlowButtonEvent<Destination>, FlowButtonEffect>
