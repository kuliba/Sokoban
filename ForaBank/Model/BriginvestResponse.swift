//
//  BriginvestResponse.swift
//  ForaBank
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

struct BriginvestResponse<T:Decodable>: Decodable {
    
    var result: String?
    var errorMessage: String?
    var data: T?
    
}
