//
//  PrintFormType.swift
//  Vortex
//
//  Created by Max Gribov on 02.02.2022.
//

import Foundation

enum PrintFormType: String, Codable, Hashable, Unknownable {
    
    case `internal`
    case addressing_cash
    case addressless
    case c2b
    case changeOutgoing
    case charity
    case closeAccount
    case closeDeposit
    case contactAddressless
    case digitalWallets
    case direct
    case education
    case external
    case housingAndCommunalService
    case insurance
    case internet
    case journey
    case mobile
    case networkMarketing
    case newDirect
    case repaymentLoansAndAccounts
    case returnOutgoing
    case sberQR
    case sbp
    case security
    case socialAndGames
    case sticker
    case taxAndStateService
    case transport
    case unknown
}
