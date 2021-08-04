//
//  DoubleInStringExtension.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import Foundation

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
