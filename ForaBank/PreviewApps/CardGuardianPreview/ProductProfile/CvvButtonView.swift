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
                get: { state?.cvvAlert() },
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: event) }
        )
    }
}

enum CvvButtonEvent {
    
    case showAlert(AlertModelOf<ProductProfileNavigation.Event>)
    case closeAlert
}

extension AlertModelOf<ProductProfileNavigation.Event> {
    
    func cvvAlert() -> AlertModelOf<CvvButtonEvent>? {
                
        return .init(
            id: self.id,
            title: self.title,
            message: self.message,
            primaryButton: .init(
                type: .cancel,
                title: self.primaryButton.title,
                event: .closeAlert
            )
        )
    }
}

#Preview {
    CvvButtonView.init(
        state: nil,
        event: {_ in })
} 
