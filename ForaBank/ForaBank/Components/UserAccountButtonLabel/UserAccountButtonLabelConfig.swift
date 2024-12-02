//
//  UserAccountButtonLabelConfig.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.12.2024.
//

import SharedConfigs
import SwiftUI

struct UserAccountButtonLabelConfig: Equatable {
    
    let avatar: Avatar
    let logo: Logo
    let name: TextConfig
    
    struct Avatar: Equatable {
        
        let color: Color
        let frame: CGSize
        let image: Image
    }
    
    struct Logo: Equatable {
        
        let color: Color
        let frame: CGSize
        let image: Image
        let offset: CGSize
    }
}
