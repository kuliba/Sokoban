//
//  RoundedDoubleExtension.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.08.2021.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
