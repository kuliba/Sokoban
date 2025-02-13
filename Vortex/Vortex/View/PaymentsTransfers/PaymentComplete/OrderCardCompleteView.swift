//
//  OrderCardCompleteView.swift
//
//
//  Created by Igor Malyarov on 08.02.2025.
//

import Combine
import PaymentCompletionUI
import PaymentComponents
import SwiftUI
import UIPrimitives

/// - Note: Simplified `PaymentCompleteView`
struct OrderCardCompleteView: View {
    
    let state: State
    let action: () -> Void
    let makeIconView: MakeIconView
    
    var body: some View {
        
        VStack {
            
            statusView()
            Spacer()
            heroButton()
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension OrderCardCompleteView {
    
    typealias State = PaymentCompletion.Status
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    typealias Config = PaymentCompletionConfig
}

private extension OrderCardCompleteView {
    
    func statusView() -> some View {
        
        PaymentCompletionStatusView(
            state: .init(formattedAmount: "", merchantIcon: nil, status: state),
            makeIconView: makeIconView,
            config: .orderCard
        )
    }
    
    func heroButton() -> some View {
        
        PaymentComponents.ButtonView.goToMain(goToMain: action)
    }
}

#if DEBUG
struct OrderCardCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            orderCardCompleteView(.inflight)
            orderCardCompleteView(.rejected)
        }
    }
    
    private static func orderCardCompleteView(
        _ state: PaymentCompletion.Status
    ) -> some View {
        
        OrderCardCompleteView(
            state: state,
            action: { print("hero action") },
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
