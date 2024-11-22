//
//  PaymentsTransfersCorporate.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import PayHubUI

typealias PaymentsTransfersCorporate = PaymentsTransfersCorporateDomain.Binder

typealias PaymentsTransfersCorporateDomain = PayHubUI.PaymentsTransfersCorporateDomain<PaymentsTransfersCorporateSelect, PaymentsTransfersCorporateNavigation>

enum PaymentsTransfersCorporateSelect {}
enum PaymentsTransfersCorporateNavigation {}
