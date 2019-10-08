//
//  File.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation
import Mapper

class AboutItem: IAboutItem {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}





    class LaonSchedules: Mappable {
        let actionTypeBrief: String?
        let userAnnual: Double?
        let principalDebt: Double?
        let loanID: String?
        let collapsed: Bool
        required init(map: Mapper) throws {
            try principalDebt = map.from("principalDebt")
            try userAnnual = map.from("userAnnual")
            try loanID = map.from("loanId")
            try collapsed = map.from("collapsed")
            try actionTypeBrief = map.from("actionTypeBrief")
        }
        init( principalDebt: Double? = nil, userAnnual: Double? = nil,  loanID: String? = nil, collapsed: Bool = false, actionTypeBrief: String? = nil) {
            self.userAnnual = userAnnual
            self.principalDebt = principalDebt
            self.loanID = loanID
            self.collapsed = collapsed
            self.actionTypeBrief = actionTypeBrief


          }
        
            

    


}

