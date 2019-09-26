//
//  Services.swift
//  ForaBank
//
//  Created by Дмитрий on 20/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import Mapper


struct Operations: Mappable {
   
    var name: String?
    var operators: Operators?
    


     init(map: Mapper) throws {
        try name = map.from("name")
    }}

struct  Operators: Mappable{
    var nameList: nameList?
    
     init(map: Mapper) throws {
        try nameList = map.from("nameList")
      }
}
struct nameList: Mappable {
    var value : String?
    init(map: Mapper) throws {
        try value = map.from("value")
    }
}







