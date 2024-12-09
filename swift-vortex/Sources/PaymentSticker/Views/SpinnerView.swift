//
//  SpinnerView.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 19.10.2023.
//

import SwiftUI

// MARK: - View

struct SpinnerRefreshView: View {
    
    @State var degrees: Double = 0.01
    
    let icon: Image
    let duration: Double
    let iconSize: CGSize
    
    init(
        icon: Image,
        duration: Double = 1,
        iconSize: CGSize = .init(width: 48, height: 48)
    ) {
        self.icon = icon
        self.duration = duration
        self.iconSize = iconSize
    }
    
    var body: some View {
        
        icon
            .renderingMode(.original)
            .resizable()
            .frame(width: iconSize.width, height: iconSize.height)
            .rotation3DEffect(
                .degrees(degrees), axis: (x: 0, y: 1, z: 0), anchor: .center, perspective: 0.1)
            .animation(.easeInOut(duration: duration).repeatForever(), value: degrees)
            .onAppear {
                
                withAnimation {
                    degrees += 180
                }
            }
    }
}

// MARK: - Previews

struct SpinnerRefreshViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        SpinnerRefreshView(icon: .init("Logo Vortex Bank"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
