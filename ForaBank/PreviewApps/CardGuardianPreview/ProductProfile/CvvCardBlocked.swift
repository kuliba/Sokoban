//
//  CvvCardBlocked.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 15.02.2024.
//

import SwiftUI
import ProductProfile

struct CvvCardBlocked: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel
        
    var body: some View {
        
        showCVV()
    }
    
    private func showCVV() -> some View {
        
        Button(action: viewModel.showAlertIfCardBlocked) {
            Text("CVV")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .cornerRadius(5)
        }
        .alert(
            item: .init(
                get: { viewModel.state.alert },
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: viewModel.event) }
        )
    }
}

#Preview {
    CvvCardBlocked.card
}
