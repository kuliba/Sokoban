//
//  DepositInfoDataItem.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 2/3/22.
//

import Foundation

//FIXME: rename to DepositInfoData after refactoring
class DepositInfoDataItem: Decodable, Equatable {

	let balance: Double
	let dateEnd: Date?
	let dateNext: Date
	let dateOpen: Date
	let id: Int
	let initialAmount: Double
	let interestRate: Double
	let sumAccInt: Double
	let sumCredit: Double?
	let sumDebit: Double?
	let sumPayInt: Double
	let termDay: String?
    let sumPayPrc: Double?
    
    internal init(balance: Double, dateEnd: Date?, dateNext: Date, dateOpen: Date, id: Int, initialAmount: Double, interestRate: Double, sumAccInt: Double, sumCredit: Double?, sumDebit: Double?, sumPayInt: Double, termDay: String?, sumPayPrc: Double?) {
        
        self.id = id
        self.balance = balance
        self.dateEnd = dateEnd
        self.dateNext = dateNext
        self.dateOpen = dateOpen
        self.initialAmount = initialAmount
        self.interestRate = interestRate
        self.sumAccInt = sumAccInt
        self.sumCredit = sumCredit
        self.sumDebit = sumDebit
        self.sumPayInt = sumPayInt
        self.termDay = termDay
        self.sumPayPrc = sumPayPrc
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case balance, dateEnd, dateNext, dateOpen, id, initialAmount, interestRate, sumAccInt, sumCredit, sumDebit, sumPayInt, termDay, sumPayPrc
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        balance = try container.decode(Double.self, forKey: .balance)
        
        if let dateEnd = try container.decodeIfPresent(Int.self, forKey: .dateEnd) {
            
            self.dateEnd = Date(timeIntervalSince1970: TimeInterval(dateEnd / 1000))
            
        } else {
            
            self.dateEnd = nil
        }

        let dateNext = try container.decode(Int.self, forKey: .dateNext)
        self.dateNext = Date(timeIntervalSince1970: TimeInterval(dateNext / 1000))
        
        let dateOpen = try container.decode(Int.self, forKey: .dateOpen)
        self.dateOpen = Date(timeIntervalSince1970: TimeInterval(dateOpen / 1000))
        
        id = try container.decode(Int.self, forKey: .id)
        initialAmount = try container.decode(Double.self, forKey: .initialAmount)
        interestRate = try container.decode(Double.self, forKey: .interestRate)
        sumAccInt = try container.decode(Double.self, forKey: .sumAccInt)
        sumCredit = try container.decodeIfPresent(Double.self, forKey: .sumCredit)
        sumDebit = try container.decodeIfPresent(Double.self, forKey: .sumDebit)
        sumPayInt = try container.decode(Double.self, forKey: .sumPayInt)
        termDay = try container.decodeIfPresent(String.self, forKey: .termDay)
        sumPayPrc = try container.decodeIfPresent(Double.self, forKey: .sumPayPrc)
    }
    
    static func == (lhs: DepositInfoDataItem, rhs: DepositInfoDataItem) -> Bool {
        return rhs.id == lhs.id
    }
}
