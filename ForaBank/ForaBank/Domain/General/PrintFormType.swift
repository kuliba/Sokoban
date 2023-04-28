//
//  PrintFormType.swift
//  ForaBank
//
//  Created by Max Gribov on 02.02.2022.
//

import Foundation

enum PrintFormType: String, Codable, Unknownable {
    
    case sbp
    case direct
    case newDirect
    case addressless
    case addressing_cash
    case `internal`
    case external
    case mobile
    case internet
    case transport
    case taxAndStateService
    case contactAddressless
    case housingAndCommunalService
    case c2b
    case closeDeposit
    case closeAccount
    case unknown
}
