//
//  QRFlowButtonModel.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import PayHub
import RxViewModel

public typealias QRFlowButtonModel<Destination> = RxViewModel<FlowButtonState<Destination>, FlowButtonEvent<Destination>, FlowButtonEffect>
