//
//  VerticalSpacingView.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import SwiftUI

// TODO: сделать негативный case

struct VerticalSpacingView: View {
    
    let model: UILanding.VerticalSpacing
    let config: UILanding.VerticalSpacing.Config
    
    init(model: UILanding.VerticalSpacing, config: UILanding.VerticalSpacing.Config) {
        
        self.model = model
        self.config = config
    }
    
    var body: some View {
        
        Rectangle()
            .frame(height: config.value(byType: model.spacingType))
            .foregroundColor( config.backgroundColor(model.backgroundColor))
            .accessibilityIdentifier("VerticalSpacingRectangle")
    }
}

struct VerticalSpacingView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack{
            
            VerticalSpacingView(
                model: .init(backgroundColor: .black, spacingType: .negativeOffset),
                config: .defaultValue)
            .border(.yellow)
            
            VerticalSpacingView(
                model: .init(backgroundColor: .white, spacingType: .big),
                config: .defaultValue)
            .border(.green)
            
            VerticalSpacingView(
                model: .init(backgroundColor: .white, spacingType: .small),
                config: .defaultValue)
            .border(.red)
        }
    }
}

