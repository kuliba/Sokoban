//
//  PaymentsContinueButtonView.swift
//  ForaBank
//
//  Created by Max Gribov on 27.10.2022.
//

import SwiftUI

extension PaymentsContinueButtonView {
    
    class ViewModel: PaymentsParameterViewModel {

        let title: String
        
        init(title: String) {
            
            self.title = title
            super.init(source: Payments.ParameterMock(id: "", value: nil))
        }
    }
}

//MARK: - Action

extension PaymentsParameterViewModelAction {

    enum ContinueButton {
    
        struct DidTapped: Action {}
    }
}

struct PaymentsContinueButtonView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PaymentsContinueViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsContinueButtonView()
    }
}
