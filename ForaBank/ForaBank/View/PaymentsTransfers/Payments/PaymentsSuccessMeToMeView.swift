//
//  PaymentsSuccessMeToMeView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI

struct PaymentsSuccessMeToMeView: View {
    
    @ObservedObject var viewModel: PaymentsSuccessMeToMeViewModel
    
    var body: some View {
        
        PaymentsSuccessView(viewModel: viewModel.successViewModel)
            .background(Color.mainColorsWhite)
            .sheet(item: $viewModel.sheet) { sheet in
                
                switch sheet.type {
                case let .printForm(printViewModel):
                    PrintFormView(viewModel: printViewModel)
                    
                case let .detailInfo(detailViewModel):
                    OperationDetailInfoView(viewModel: detailViewModel)
                }
            }
    }
}

struct PaymentsSuccessMeToMeView_Previews: PreviewProvider {
    static var previews: some View {
        
        PaymentsSuccessMeToMeView(viewModel: .init(
            .emptyMock,
            state: .success(.complete, 0),
            confirmationData: .init(
                debitAmount: 1000,
                fee: nil,
                creditAmount: nil,
                currencyRate: nil,
                currencyPayer: .init(description: "RUB"),
                currencyPayee: nil,
                needMake: true)))
    }
}
