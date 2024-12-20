//
//  DigitView.swift
//  
//
//  Created by Andryusina Nataly on 17.07.2023.
//

import SwiftUI

struct DigitView: View {
    
    let value: String?
    let config: Config
    
    var body: some View {
        
        VStack{
            
            if let value = value {
                
                Text(value)
                    .font(config.font)
                    .multilineTextAlignment(.center)
                    .foregroundColor(config.foregroundColor)
            }
            
            Spacer()
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 40, height: 1)
                .background(config.filColor)
        }
        .frame(height: 50)
    }
}

struct DigitView_Previews : PreviewProvider {
    
    static var previews: some View {
        
        DigitView(value: "1",
                  config: .init(
                    foregroundColor: .black,
                    font: .body,
                    filColor: .gray
                  )
        )
    }
}

