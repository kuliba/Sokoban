//
//  PaymentCompletionConfig.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SharedConfigs
import SwiftUI

public struct PaymentCompletionConfig: Equatable {
    
    let statuses: Statuses
    
    public init(statuses: Statuses) {
        
        self.statuses = statuses
    }
}

extension PaymentCompletionConfig {
    
    public struct Statuses: Equatable {
        
        public let completed: Status
        public let inflight: Status
        public let rejected: Status
        public let fraudCancelled: Status
        public let fraudExpired: Status
        
        public init(
            completed: Status,
            inflight: Status,
            rejected: Status,
            fraudCancelled: Status,
            fraudExpired: Status
        ) {
            self.completed = completed
            self.inflight = inflight
            self.rejected = rejected
            self.fraudCancelled = fraudCancelled
            self.fraudExpired = fraudExpired
        }
    }
}

extension PaymentCompletionConfig.Statuses {
    
    public struct Status: Equatable {
        
        public let content: Content
        public let config: Config
        
        public init(
            content: Content,
            config: Config
        ) {
            self.content = content
            self.config = config
        }
    }
}

extension PaymentCompletionConfig.Statuses.Status {
    
    public struct Content: Equatable {
        
        public let logo: Image
        public let title: String
        public let subtitle: String?
        
        public init(
            logo: Image,
            title: String,
            subtitle: String?
        ) {
            self.logo = logo
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    public struct Config: Equatable {
        
        public let amount: TextConfig
        public let icon: Icon
        public let logoHeight: CGFloat
        public let title: TextConfig
        public let subtitle: TextConfig
        
        public init(
            amount: TextConfig,
            icon: Icon,
            logoHeight: CGFloat,
            title: TextConfig,
            subtitle: TextConfig
        ) {
            self.amount = amount
            self.icon = icon
            self.logoHeight = logoHeight
            self.title = title
            self.subtitle = subtitle
        }
    }
}

extension PaymentCompletionConfig.Statuses.Status.Config {
    
    public struct Icon: Equatable {
        
        public let foregroundColor: Color
        public let backgroundColor: Color
        public let innerSize: CGSize
        public let outerSize: CGSize
        
        public init(
            foregroundColor: Color,
            backgroundColor: Color,
            innerSize: CGSize,
            outerSize: CGSize
        ) {
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.innerSize = innerSize
            self.outerSize = outerSize
        }
    }
}
