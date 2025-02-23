//
//  Form.swift
//  
//
//  Created by Andryusina Nataly on 27.11.2024.
//

import LoadableState
import SwiftUI

public struct Form<Confirmation> {
    
    public let constants: Constants
    
    public var confirmation: Loadable<Confirmation>
    public var consent = true
    public var topUp: TopUp
    public var otp: String?
    public var orderAccountResponse: OrderAccountResponse?
    
    public var amount: Double?
    public var sourceAccountId: Int?
    public var sourceCardId: Int?

    public init(
        constants: Constants,
        confirmation: Loadable<Confirmation> = .loaded(nil),
        consent: Bool = true,
        topUp: TopUp,
        otp: String? = nil,
        orderAccountResponse: OrderAccountResponse? = nil,
        amount: Double? = nil,
        sourceAccountId: Int? = nil,
        sourceCardId: Int? = nil
    ) {
        self.constants = constants
        self.confirmation = confirmation
        self.consent = consent
        self.topUp = topUp
        self.otp = otp
        self.orderAccountResponse = orderAccountResponse
        self.amount = amount
        self.sourceAccountId = sourceAccountId
        self.sourceCardId = sourceCardId
    }
}
