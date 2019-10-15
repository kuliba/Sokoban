/*
 * Copyright (C) 2017-2019 Brig Invest ltd. All rights reserved.
 * CONFIDENTIAL
 *
 * Авторское право (C) 2017-2019 OОО "Бриг Инвест". Все права защищены.
 * КОНФИДЕНЦИАЛЬНО
 */

import Foundation

struct CardBanks: Decodable {
    let banks: [CardBank]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var banks = [CardBank]()
        while !container.isAtEnd {
            let bank = try! container.decode(CardBank.self)
            banks.append(bank)
        }
        self.banks = banks
    }
}

struct CardBank : Decodable {
    let name: String?
    let nameEn: String?
    let alias: String?
    let backgroundColor: String?
    let backgroundColors: [String]?
    let textColor: String?
    let prefixes: [String]?
    let logoStyle: String?
    let backgroundLightness: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case nameEn
        case alias
        case logoStyle
        case backgroundColor
        case backgroundColors
        case textColor = "text"
        case prefixes
        case backgroundLightness
    }
}
