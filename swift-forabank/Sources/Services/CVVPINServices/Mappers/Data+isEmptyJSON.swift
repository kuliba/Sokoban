//
//  Data+isEmptyJSON.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.10.2023.
//

import Foundation

extension Data {
    
    var isEmptyJSON: Bool { isEmpty || self == .init("{}".utf8) }
}
