//
//  DelayWrappedAction.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 18.04.2023.
//

import Foundation

struct DelayWrappedAction: Action {
    
    let delayMS: Int
    let action: Action
}
