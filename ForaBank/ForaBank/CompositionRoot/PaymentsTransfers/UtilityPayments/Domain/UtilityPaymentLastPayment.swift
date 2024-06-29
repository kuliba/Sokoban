//
//  UtilityPaymentLastPayment.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.05.2024.
//

import LatestPayments
import Foundation
import RemoteServices

typealias UtilityPaymentLastPayment = RemoteServices.ResponseMapper.LatestServicePayment

    let name: String
extension UtilityPaymentLastPayment: Identifiable {
    
    public var id: String { puref }
}
