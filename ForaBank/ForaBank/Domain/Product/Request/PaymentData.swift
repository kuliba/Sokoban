//
//  PaymentData.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 30.05.2022.
//

import Foundation

class PaymentData: Codable {

    let date: Date
    let account: String
    let amount: Double
    let currency: String
    //FIXME: remove commented property if really not used
    //let paymentDate: String
    let purpose: String

    init (date: Date, account: String, currency: String, amount: Double, purpose: String) {

        self.date = date
        self.account = account
        self.currency = currency
        self.amount = amount
        self.purpose = purpose
    }

    private enum CodingKeys: String, CodingKey {
        case date, account, currency, amount, purpose
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateValue = try container.decode(Int.self, forKey: .date)
        date = Date(timeIntervalSince1970: TimeInterval(dateValue / 1000))
        
        account = try container.decode(String.self, forKey: .account)
        currency = try container.decode(String.self, forKey: .currency)
        amount = try container.decode(Double.self, forKey: .amount)
        purpose = try container.decode(String.self, forKey: .purpose)
    }
}

extension PaymentData: Equatable {

    static func == (lhs: PaymentData, rhs: PaymentData) -> Bool {
        (lhs.date == rhs.date) && (lhs.account == rhs.account)
    }
}
