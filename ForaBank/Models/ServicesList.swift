//
//  Services.swift
//  ForaBank
//
//  Created by Дмитрий on 20/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

class Operations:Codable {
    let name: String?


    init( name: String? = nil) {
        self.name = name
    

    }
}
