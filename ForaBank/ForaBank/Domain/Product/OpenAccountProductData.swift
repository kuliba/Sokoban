//
//  AccountProductData.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.06.2022.
//

import CoreMedia

// MARK: - OpenAccountProductData

struct OpenAccountProductData: Codable, Equatable {

    let currencyAccount: String
    let open: Bool
    let breakdownAccount: String
    let accountType: String
    let currencyCode: Int
    let currency: Currency
    let designMd5hash: String
    let designSmallMd5hash: String
    let detailedConditionUrl: String
    let detailedRatesUrl: String?
    let txtConditionList: [TxtConditionList]

    // MARK: - TxtConditionList

    struct TxtConditionList: Codable, Equatable {

        let name: String
        let descriptoin: String
        let type: ColorType

        enum ColorType: String, Codable, Unknownable {

            case green = "GREEN"
            case unknown
        }

        enum CodingKeys: String, CodingKey {

            case name
            case descriptoin
            case type
        }

        //TODO: remove later, createted because of unknown case
        init(from decoder: Decoder) throws {

            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            descriptoin = try container.decode(String.self, forKey: .descriptoin)

            let colorType = try container.decode(ColorType.self, forKey: .type)
            type = ColorType(rawValue: colorType.rawValue) ?? .unknown
        }

        func encode(to encoder: Encoder) throws {

            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(descriptoin, forKey: .descriptoin)
            try container.encode(type.rawValue, forKey: .type)
        }

        static func == (lhs: TxtConditionList, rhs: TxtConditionList) -> Bool {

            let equalities = [
                lhs.name == rhs.name,
                lhs.descriptoin == rhs.descriptoin,
                lhs.type == rhs.type
            ]

            return equalities.reduce(true) { result, equality -> Bool in
                return result && equality
            }
        }
    }

    enum CodingKeys: String, CodingKey {

        case currencyAccount
        case open
        case breakdownAccount
        case accountType
        case currencyCode
        case currency
        case designMd5hash
        case designSmallMd5hash
        case detailedConditionUrl
        case detailedRatesUrl
        case txtConditionList
    }

    //TODO: remove later, createted because of unknown case
    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencyAccount = try container.decode(String.self, forKey: .currencyAccount)
        open = try container.decode(Bool.self, forKey: .open)
        breakdownAccount = try container.decode(String.self, forKey: .breakdownAccount)
        accountType = try container.decode(String.self, forKey: .accountType)
        currencyCode = try container.decode(Int.self, forKey: .currencyCode)
        designMd5hash = try container.decode(String.self, forKey: .designMd5hash)
        designSmallMd5hash = try container.decode(String.self, forKey: .designSmallMd5hash)
        detailedConditionUrl = try container.decode(String.self, forKey: .detailedConditionUrl)
        detailedRatesUrl = try container.decodeIfPresent(String.self, forKey: .detailedRatesUrl)
        txtConditionList = try container.decode([TxtConditionList].self, forKey: .txtConditionList)
        currency = try container.decode(Currency.self, forKey: .currency)
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currencyAccount, forKey: .currencyAccount)
        try container.encode(open, forKey: .open)
        try container.encode(breakdownAccount, forKey: .breakdownAccount)
        try container.encode(accountType, forKey: .accountType)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(currency, forKey: .currency)
        try container.encode(designMd5hash, forKey: .designMd5hash)
        try container.encode(designSmallMd5hash, forKey: .designSmallMd5hash)
        try container.encode(detailedConditionUrl, forKey: .detailedConditionUrl)
        try container.encode(detailedRatesUrl, forKey: .detailedRatesUrl)
        try container.encode(txtConditionList, forKey: .txtConditionList)
    }

    static func == (lhs: OpenAccountProductData, rhs: OpenAccountProductData) -> Bool {

        let equalities = [
            lhs.currencyAccount == rhs.currencyAccount,
            lhs.open == rhs.open,
            lhs.breakdownAccount == rhs.breakdownAccount,
            lhs.accountType == rhs.accountType,
            lhs.currencyCode == rhs.currencyCode,
            lhs.currency == rhs.currency,
            lhs.designMd5hash == rhs.designMd5hash,
            lhs.designSmallMd5hash == rhs.designSmallMd5hash,
            lhs.detailedConditionUrl == rhs.detailedConditionUrl,
            lhs.detailedRatesUrl == rhs.detailedRatesUrl,
            lhs.txtConditionList == rhs.txtConditionList
        ]

        return equalities.reduce(true) { result, equality -> Bool in
            return result && equality
        }
    }
}
