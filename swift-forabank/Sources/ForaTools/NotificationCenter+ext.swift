//
//  NotificationCenter+ext.swift
//  
//
//  Created by Дмитрий Савушкин on 04.07.2024.
//

import Foundation
import Combine

public extension NotificationCenter {
    
    func observe(
        notificationName: String,
        userInfoKey: String
    ) -> AnyPublisher<String, Never> {
        
        NotificationCenter.default
            .publisher(for: Notification.Name(rawValue: notificationName))
            .compactMap { $0.userInfo?[userInfoKey] as? String }
            .eraseToAnyPublisher()
    }
}
