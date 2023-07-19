//
//  RepeatButtonView.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

struct RepeatButtonView: View {
    
    let config: RepeatButtonView.Config
    
    var body: some View {
        
        Button(action: config.action) {
            
            Text(config.title)
                .font(config.font)
                .multilineTextAlignment(.center)
                .foregroundColor(config.foregroundColor)
                .frame(width: 140, height: 16, alignment: .center)
        }
        .padding()
        .frame(width: 140, height: 24)
        .background(config.backgroundColor)
        .clipShape(Capsule())
    }
}

struct RepeatButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        RepeatButtonView(config: .defaultValue)
    }
}
