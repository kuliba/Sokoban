//
//  PaymentsTransfersSwitcher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHubUI

typealias PaymentsTransfersSwitcher = ProfileSwitcherModel<PaymentsTransfersCorporate, PaymentsTransfersPersonal>

import Combine

protocol PaymentsTransfersSwitcherProtocol {
    
    var hasDestination: AnyPublisher<Bool, Never> { get }
}
