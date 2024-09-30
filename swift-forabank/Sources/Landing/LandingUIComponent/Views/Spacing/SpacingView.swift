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
            .frame(height: model.sizeDp)
            .foregroundColor( config.backgroundColor(model.backgroundColor))
            .accessibilityIdentifier("Spacing")
    }
}

struct SpacingView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack{
            
            SpacingView(
                model: .init(backgroundColor: .black, sizeDp: 32),
                config: .defaultValue)
            .border(.yellow)
            
            SpacingView(
                model: .init(backgroundColor: .white, sizeDp: 64),
                config: .defaultValue)
            .border(.green)
            
            SpacingView(
                model: .init(backgroundColor: .white, sizeDp: 10),
                config: .defaultValue)
            .border(.red)
        }
    }
}

