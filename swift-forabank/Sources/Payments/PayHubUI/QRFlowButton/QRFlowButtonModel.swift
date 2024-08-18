//
//  QRFlowButtonModel.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import PayHub
import RxViewModel

typealias QRFlowButtonModel<Destination> = RxViewModel<QRFlowButtonState<Destination>, QRFlowButtonEvent<Destination>, QRFlowButtonEffect>
