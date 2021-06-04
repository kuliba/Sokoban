//
//  PaymentsModel.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import Foundation

struct PaymentsModel: Hashable {
    var id: Int
    var name: String
    var iconName: String?
    var avatarImageName: String?
    var controllerName: String
    var description: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
