//
//  CardBrand.swift
//  ForaBank
//
//  Created by Sergey on 16/01/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

enum CardBrand: RawRepresentable, CaseIterable {
    case visa
    case masterCard
    case americanExpress
    case dinersClub
    case discover
    case jcb
    case unionPay
    case maestro
    case mir
    
    var rawValue: (String, String){
        switch self {
        case .visa: return ("^4\\d*$", "visa-colored.png")
        case .masterCard: return ("^(5[1-5]|222[1-9]|2[3-6]|27[0-1]|2720)\\d*$", "master-card-colored.png")
        case .americanExpress: return ("^3[47]\\d*$", "american-express-colored.png")
        case .dinersClub: return ("^3(0[0-5]|[689])\\d*$", "diners-club-colored.png")
        case .discover: return ("^(6011|65|64[4-9])\\d*$", "discover-colored.png")
        case .jcb: return ("^(2131|1800|35)\\d*$", "jcb-colored.png")
        case .unionPay: return ("^62[0-5]\\d*$", "unionpay-colored.png")
        case .maestro: return ("^(5[0678]|6304|6390|6054|6271|67)\\d*$", "maestro-colored.png")
        case .mir: return ("^22\\d*$", "mir-colored.png")
        }
    }
    
    init?(rawValue: (String, String)) {
        switch rawValue {
        case ("^4\\d*$", "visa-colored.png"): self = .visa
        case ("^(5[1-5]|222[1-9]|2[3-6]|27[0-1]|2720)\\d*$", "master-card-colored.png"): self = .masterCard
        case ("^3[47]\\d*$", "american-express-colored.png"): self = .americanExpress
        case ("^3(0[0-5]|[689])\\d*$", "diners-club-colored.png"): self = .dinersClub
        case ("^(6011|65|64[4-9])\\d*$", "discover-colored.png"): self = .discover
        case ("^(2131|1800|35)\\d*$", "jcb-colored.png"): self = .jcb
        case ("^62[0-5]\\d*$", "unionpay-colored.png"): self = .unionPay
        case ("^(5[0678]|6304|6390|6054|6271|67)\\d*$", "maestro-colored.png"): self = .maestro
        case ("^22\\d*$", "mir-colored.png"): self = .mir
        default:
            return nil
        }
    }
}
