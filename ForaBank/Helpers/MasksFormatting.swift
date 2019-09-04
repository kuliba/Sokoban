//
//  MasksFormatting.swift
//  ForaBank
//
//  Created by Бойко Владимир on 03/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

func maskedString(string: String, mask: Array<Int>) -> String {
    var temp = string.map { String($0) }
    let parts = mask.map { (item) -> [String] in
        let part = temp[0...item - 1]
        temp = Array(temp.suffix(from: item))
        return Array(part)
    }

    let joinedParts = parts.map({ $0.joined() })
    return Array(joinedParts).joined(separator: "•")
}

func maskedAccount(with string: String) -> String {
    let mask = [5, 3, 1, 4, 7]
    return maskedString(string: string, mask: mask)
}

func maskedCard(with string: String) -> String {
    let mask = [4, 4, 4, 4]
    return maskedString(string: string, mask: mask)
}
