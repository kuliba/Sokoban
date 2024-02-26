//
//  CvvButtonView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 15.02.2024.
//

import SwiftUI
import ProductProfile
import CardGuardianModule
import UIPrimitives

struct CvvButtonView: View {
    
    let state: AlertModelOf<ProductProfileNavigation.Event>?
    let event: (CvvButtonEvent) -> Void
        
    var body: some View {
        
        showCVV()
    }
    
    private func showCVV() -> some View {
        
        Button(action: { self.event(.showAlert(.alertCVV())) }) {
            Text("CVV")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .cornerRadius(5)
        }
        .alert(
            item: .init(
                get: { state },
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: event) }
        )
    }
}

enum CvvButtonEvent {
    
    case open(ProductProfileNavigation.CardGuardianRoute)
    case productProfile(ProductProfileEvent)
}


#Preview {
    CvvButtonView.cardUnblokedOnMain
}
