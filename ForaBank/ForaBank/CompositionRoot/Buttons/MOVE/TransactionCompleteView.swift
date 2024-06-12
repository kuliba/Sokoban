//
//  TransactionCompleteView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.06.2024.
//

import PaymentComponents
import SwiftUI

#warning("move")

struct TransactionCompleteView: View {
    
    let state: State
    let goToMain: () -> Void
    let config: Config
    
    var body: some View {
        
        VStack {
            
            buttons()
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            PaymentComponents.ButtonView.goToMain(goToMain: goToMain)
        }
        .padding(.top, 88)
        .padding(.bottom)
        .padding(.horizontal)
    }
}

extension TransactionCompleteView {
    
    typealias Config = TransactionCompleteViewConfig
    
    struct State {
        
        let details: Details?
        
        typealias Details = TransactionDetailButton.Details
    }
}

private extension TransactionCompleteView {
    
    func buttons() -> some View {
        
        HStack {
            
            state.details.map(TransactionDetailButton.init)
        }
    }
}

extension PaymentComponents.ButtonView {
    
    static func goToMain(
        title: String = "На главный",
        color: PaymentComponents.Button.Color = .red,
        goToMain: @escaping () -> Void
    ) -> Self {
        
        self.init(
            state: .init(
                id: .buttonPay,
                value: title,
                color: color,
                action: .pay,
                placement: .bottom
            ),
            event: goToMain,
            config: .iFora
        )
    }
}

struct TransactionCompleteView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            completeView(.init(details: nil))
        }
    }
    
    private static func completeView(
        _ state: TransactionCompleteView.State
    ) -> some View {
        
        TransactionCompleteView(state: state, goToMain: {}, config: .iFora)
    }
}

#warning("extract to file")
struct TransactionCompleteViewConfig: Equatable {}
extension TransactionCompleteViewConfig {
    
    static let iFora: Self = .init()
}
