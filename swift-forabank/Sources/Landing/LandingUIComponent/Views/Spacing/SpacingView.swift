//
//  SpacingView.swift
//  
//
//  Created by Andryusina Nataly on 30.09.2024.
//

import SwiftUI

struct SpacingView: View {
    
    let model: UILanding.Spacing
    let config: UILanding.Spacing.Config
    
    init(model: UILanding.Spacing, config: UILanding.Spacing.Config) {
        
        self.model = model
        self.config = config
    }
    
    var body: some View {
        
        Rectangle()
            .frame(height: model.heightDp)
            .foregroundColor( config.backgroundColor(model.backgroundColor))
            .accessibilityIdentifier("Spacing")
    }
}

struct SpacingView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack{
            
            SpacingView(
                model: .init(backgroundColor: .black, heightDp:32),
                config: .defaultValue)
            .border(.yellow)
            
            SpacingView(
                model: .init(backgroundColor: .white, heightDp:64),
                config: .defaultValue)
            .border(.green)
            
            SpacingView(
                model: .init(backgroundColor: .white, heightDp:10),
                config: .defaultValue)
            .border(.red)
        }
    }
}

