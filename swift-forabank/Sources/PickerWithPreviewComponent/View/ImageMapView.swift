//
//  ImageMapView.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

import SwiftUI

struct ImageMapView: View {
    
    let mapImage: MapImage
    
    var body: some View {
        
        switch mapImage {
        case .placeholder:
            Color.gray.opacity(0.3)
        case let .image(image):
            image
                .resizable()
                .scaledToFit()
        }
    }
}
