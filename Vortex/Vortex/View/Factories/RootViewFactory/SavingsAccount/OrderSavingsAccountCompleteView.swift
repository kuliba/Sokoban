//
//  OrderSavingsAccountCompleteView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 21.02.2025.
//

import Combine
import PaymentCompletionUI
import PaymentComponents
import SwiftUI
import UIPrimitives

struct OrderSavingsAccountCompleteView: View {
    
    let state: State
    let action: () -> Void
    let makeIconView: MakeIconView
    
    var body: some View {
        
        VStack {
            
            statusView()
            Spacer()
            goToMainButton()
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension OrderSavingsAccountCompleteView {
    
    typealias State = PaymentCompletion.Status
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    typealias Config = PaymentCompletionConfig
}

private extension OrderSavingsAccountCompleteView {
    
    func statusView() -> some View {
        
        PaymentCompletionStatusView(
            state: .init(formattedAmount: "", merchantIcon: nil, status: state),
            makeIconView: makeIconView,
            config: .orderCard
        )
    }
    
    func goToMainButton() -> some View {
        
        PaymentComponents.ButtonView.goToMain(goToMain: action)
    }
}

#if DEBUG
struct OrderSavingsAccountCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            orderAccountCompleteView(.inflight)
            orderAccountCompleteView(.rejected)
        }
    }
    
    private static func orderAccountCompleteView(
        _ state: PaymentCompletion.Status
    ) -> some View {
        
        OrderSavingsAccountCompleteView(
            state: state,
            action: { print("goToMain action") },
            makeIconView: {
                
                return .init(
                    image: .init(systemName: $0),
                    publisher: Just(.init(systemName: $0))
                        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                )
            }
        )
    }
}
#endif
