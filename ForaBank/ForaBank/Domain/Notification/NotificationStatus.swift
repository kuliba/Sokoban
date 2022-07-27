//
//  NotificationStatus.swift
//  ForaBank
//
//  Created by Max Gribov on 09.07.2022.
//

import Foundation

enum NotificationStatus: String, Codable, Unknownable {
    
    case delivered = "DELIVERED"
    case read = "READ"
    case unknown
}
