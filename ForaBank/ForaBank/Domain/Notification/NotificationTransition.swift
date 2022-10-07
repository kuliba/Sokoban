//
//  NotificationTransition.swift
//  ForaBank
//
//  Created by Константин Савялов on 02.07.2022.
//

import Foundation

enum NotificationTransition {
    
    case history
    //FIXME: this is legacy model, change to refactored
    case me2me(RequestMeToMeModel)
    
    init(userInfo: [AnyHashable : Any]) {
        
        if let type = userInfo["type"] as? String, type == "сonsentMe2MePull" {
            
            let requestMeToMeModel: RequestMeToMeModel = .init(userInfo: userInfo)
            self = .me2me(requestMeToMeModel)
            
        } else {
            
            self = .history
        }
    }
}
