//
//  UserAccountConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 30.09.2024.
//

import Foundation
import SharedConfigs
import SwiftUI

struct UserAccountConfig {

    let fpsConfig: FpsConfig
    let infoVerificationConfig: InfoVerificationConfig
    
    struct FpsConfig {
        
        let title: TextConfig
    }

    struct InfoVerificationConfig {
        
        public let title: String
        public let titleConfig: TextConfig
        public let icon: Image
        
        public let backgroundColor: Color
        
        public init(
            title: String,
            titleConfig: TextConfig,
            icon: Image,
            backgroundColor: Color
        ) {
            self.title = title
            self.titleConfig = titleConfig
            self.icon = icon
            self.backgroundColor = backgroundColor
        }
    }
}

extension UserAccountConfig {
    
    static let preview: Self = .init(
        fpsConfig: .init(
            title: .init(
                textFont: .body,
                textColor: .red
            )
        ),
        infoVerificationConfig: .init(
            title: "При переводе через СБП отправителю не будет предложен банк по умолчанию для получения переводов",
            titleConfig: .init(textFont: .body, textColor: .black),
            icon: .init(systemName: "building.columns"),
            backgroundColor: .gray
        )
    )
}
