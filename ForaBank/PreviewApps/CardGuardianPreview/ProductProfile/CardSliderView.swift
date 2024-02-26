//
//  CardSliderView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 26.02.2024.
//

import SwiftUI
import ActivateSlider
import ProductProfile
import UIPrimitives

struct CardSliderView: View {
    
    let state: ProductProfileNavigation.State
    let event: (ProductProfileNavigation.Event) -> Void
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    CardSliderView(       
        state: .init(),
        event: { _ in }
    )
}
