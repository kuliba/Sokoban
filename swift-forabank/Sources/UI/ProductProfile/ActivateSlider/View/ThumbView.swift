//
//  ThumbView.swift
//
//
//  Created by Andryusina Nataly on 19.02.2024.
//

import SwiftUI

struct ThumbView: View {
    
    let config: ThumbConfig
    
    var body: some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(config.backgroundColor)
            Circle()
                .strokeBorder(config.foregroundColor, lineWidth: 1)
            
            config.icon
                .resizable()
                .renderingMode(.template)
                .foregroundColor(config.foregroundColor)
                .frame(width: 24, height: 24)
                .modifier(AnimationModifire(isAnimated: config.isAnimated))
        }
        .frame(width: 40, height: 40)
    }
}

struct ThumbView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            ZStack {
                Color.gray
                    .frame(width: 100, height: 100)
                ThumbView(config: SliderConfig.default.thumbConfig(.none))
            }
            
            ZStack {
                Color.gray
                    .frame(width: 100, height: 100)
                ThumbView(config: SliderConfig.default.thumbConfig(.activated))
            }
            
            ZStack {
                Color.gray
                    .frame(width: 100, height: 100)
                ThumbView(config: SliderConfig.default.thumbConfig(.inflight))
            }

            ZStack {
                Color.gray
                    .frame(width: 100, height: 100)
                ThumbView(config: SliderConfig.default.thumbConfig(.confirmActivate(1)))
            }
        }
    }
}
