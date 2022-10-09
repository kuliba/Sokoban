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
        
        if let successViewModel = viewModel.successViewModel {
            PaymentsSuccessView(viewModel: successViewModel)
                .background(Color.mainColorsWhite)
        } else {
            EmptyView()
        }
    }
}

/*
struct PaymentsSuccessMeToMeView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsSuccessMeToMeView(viewModel: .init(content: .success(.init(documentStatus: .complete, paymentOperationDetailId: 0))))
    }
}
*/
