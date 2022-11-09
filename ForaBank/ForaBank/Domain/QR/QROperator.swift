//
//  QROperator.swift
//  ForaBank
//
//  Created by Константин Савялов on 31.10.2022.
//

import Foundation

struct QROperator: Codable, Equatable {
    
    let `operator`: String
    let parameters: [QRParameter]
}
