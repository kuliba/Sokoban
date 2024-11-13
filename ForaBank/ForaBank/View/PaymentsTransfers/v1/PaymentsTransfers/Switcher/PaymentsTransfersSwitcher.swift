//
//  PaymentsTransfersSwitcher.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.08.2024.
//

import Combine
import PayHubUI

typealias PaymentsTransfersSwitcher = ProfileSwitcherModel<PaymentsTransfersCorporate, PaymentsTransfersPersonal>

protocol PaymentsTransfersSwitcherProtocol {
    
    var hasDestination: AnyPublisher<Bool, Never> { get }
}
