//
//  File.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import Foundation

class AboutItem: IAboutItem {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}

class LaonSchedules: ILoanSchedule {
    var title: String
    var value: String
    

    init(title: String, value: String) {
        self.value = value
        self.title = title
    }
}
