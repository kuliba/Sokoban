//
//  PaymentsSuccessMeToMeView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI

struct PaymentsSuccessMeToMeView: View {
    
    let viewModel: PaymentsSuccessMeToMeViewModel
    
    var body: some View {
        
        PaymentsSuccessView(viewModel: viewModel.successViewModel)
            .background(Color.mainColorsWhite)
    }
}

/*
struct PaymentsSuccessMeToMeView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsSuccessMeToMeView(viewModel: .init(content: .success(.init(documentStatus: .complete, paymentOperationDetailId: 0))))
    }
}
*/
