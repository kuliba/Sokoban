//
//  BankDefaultStore.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.02.2024.
//

import KeyChainStore
import Tagged

typealias BankDefaultStore = KeyChainStore<BankDefaultKey, Bool>

enum BankDefaultKey: String {
    
    case bankDefault
}
