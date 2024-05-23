//
//  StringValueMask.swift
//  ForaBank
//
//  Created by Max Gribov on 21.02.2022.
//

import Foundation

struct StringValueMask: Equatable {
    
    let mask: String
    let symbol: Character
    var length: Int { mask.filter{ $0 == symbol }.count }
}

extension StringValueMask {
    
    static let card = StringValueMask(mask: "#### #### #### ####", symbol: "#")
    
    static let cardForRequisites = StringValueMask(mask: "#### ##** **** ####", symbol: "#")

    static let account = StringValueMask(mask: "##### # ### #### #######", symbol: "#")
}
