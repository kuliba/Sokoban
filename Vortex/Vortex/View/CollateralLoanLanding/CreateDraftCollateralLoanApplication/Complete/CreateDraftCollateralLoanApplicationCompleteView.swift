//
//  CreateDraftCollateralLoanApplicationCompleteView.swift
//  Vortex
//
//  Created by Valentin Ozerov on 13.02.2025.
//

import Combine
import PaymentCompletionUI
import PaymentComponents
import SwiftUI
import UIPrimitives

/// - Note: Simplified `PaymentCompleteView`
struct CreateDraftCollateralLoanApplicationCompleteView: View {
    
    let state: State
    let action: () -> Void
    let makeIconView: MakeIconView
    let pdfDocumentButton: PDFDocumentButton
    let detailsButton: CollateralLoanLandingDetailsButton
    
    var body: some View {
        
        VStack {
            
            statusView()
            Spacer()
            buttons()
        }
        .safeAreaInset(edge: .bottom, content: heroButton)
        .frame(maxHeight: .infinity)
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension CreateDraftCollateralLoanApplicationCompleteView {
    
    typealias State = PaymentCompletion.Status
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    typealias Config = PaymentCompletionConfig
}

private extension CreateDraftCollateralLoanApplicationCompleteView {
    
    func statusView() -> some View {
        
        PaymentCompletionStatusView(
            state: .init(formattedAmount: "", merchantIcon: nil, status: state),
            makeIconView: makeIconView,
            config: .collateralLoanLanding
        )
    }
    
    func buttons() -> some View {
        
        HStack {
            
            pdfDocumentButton
            Color.clear.frame(width: 8)
            detailsButton
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 50)
    }
    
    func heroButton() -> some View {
        
        PaymentComponents.ButtonView.goToMain(goToMain: action)
    }
}

struct CreateDraftCollateralLoanApplicationCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            createDraftCollateralLoanApplicationCompleteView(.completed)
        }
    }
    
    private static func createDraftCollateralLoanApplicationCompleteView(
        _ state: PaymentCompletion.Status
    ) -> some View {
        
        CreateDraftCollateralLoanApplicationCompleteView(
            state: state,
            action: { print("hero action") },
            makeIconView: {
                
                return .init(
                    image: .init(systemName: $0),
                    publisher: Just(.init(systemName: $0))
                        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                )
            }, 
            pdfDocumentButton: .preview,
            detailsButton: .preview
        )
    }
}
