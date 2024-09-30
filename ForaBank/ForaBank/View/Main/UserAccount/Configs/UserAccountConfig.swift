//
//  UserAccountConfig.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 30.09.2024.
//

import Foundation
import SharedConfigs

struct UserAccountConfig {

    let fpsConfig: FpsConfig
    
    struct FpsConfig {
        
        let title: TextConfig
    }
}

extension UserAccountConfig {
    
    static let preview: Self = .init(
        fpsConfig: .init(
            title: .init(
                textFont: .body,
                textColor: .red
            )
        )
    )
}
