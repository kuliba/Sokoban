//
//  PushHistoryModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.06.2022.
//

import Foundation

struct PushHistoryModel {
    
    var sections: String
    var items: [PushHistoryItems]
    
    internal init(sections: String, items: [PushHistoryModel.PushHistoryItems]) {
        self.sections = sections
        self.items = items
    }
    
    struct PushHistoryItems {
        
        var date: String?
        var title: String?
        var text: String?
        var type: String?
        var state: String?
        
        init(with data: GetNotificationsCellModel) {
           
           self.date = data.date
           self.title = data.title
           self.text = data.text
           self.type = data.type
           self.state = data.state
        }
    }
}
