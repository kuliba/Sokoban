//
//  UserAccountButtonLabel.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.12.2024.
//

import SwiftUI

struct UserAccountButtonLabel: View {
    
    let avatar: Image?
    let name: String
    let config: UserAccountButtonLabelConfig
    
    var body: some View {
        
        HStack {
            
            icon()
            name.text(withConfig: config.name)
                .accessibilityIdentifier("mainUserName")
        }
    }
}

private extension UserAccountButtonLabel {
    
    func icon() -> some View {
        
        ZStack {
            
            if let avatar {
                
                avatarView(avatar)
                
            } else {
                
                avatarPlaceholder()
            }
            
            offsettedLogo()
        }
    }
    
    func avatarView(_ avatar: Image) -> some View {
        
        avatar
            .resizable()
            .scaledToFill()
            .frame(config.avatar.frame)
            .clipShape(Circle())
    }
    
    func avatarPlaceholder() -> some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(config.avatar.color)
                .frame(config.avatar.frame)
            
            config.avatar.image
                .renderingMode(.template)
                .foregroundColor(.iconGray)
        }
    }
    
    func offsettedLogo() -> some View {
        
        ZStack{
            
            Circle()
                .foregroundColor(config.logo.color)
                .frame(config.logo.frame)
            
            config.logo.image
                .renderingMode(.original)
        }
        .offset(config.logo.offset)
    }
}
