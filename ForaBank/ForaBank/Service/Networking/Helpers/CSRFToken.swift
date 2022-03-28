//
//  CSRFToken.swift
//  ForaBank
//
//  Created by Mikhail on 19.06.2021.
//

import Foundation
import Combine

struct CSRFToken {
    static var token: String? {
        didSet {
            print("DEBUG: CSRFToken установлен")
        }
    }
}
