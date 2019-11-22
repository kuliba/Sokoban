//
//  CardProviderType.swift
//  ForaBank
//
//  Created by Бойко Владимир on 22.11.2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

enum PaymentProviderType {
    case visa
    case mastercard
    case mir
    case none

    var logoImageName: String? {
        switch self {
        case .visa:
            return "visa-colored"
        case .mastercard:
            return "master-card-colored"
        case .mir:
            return "mir-colored"
        case .none:
            return nil
        }
    }
}
