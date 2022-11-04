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
            mode: .meToMe,
            state: .success(.complete, 0),
            responseData: .init(
                amount: nil,
                creditAmount: nil,
                currencyAmount: nil,
                currencyPayee: .init(description: "RUB"),
                currencyPayer: nil,
                currencyRate: nil,
                debitAmount: 1000,
                fee: nil,
                needMake: true,
                needOTP: false,
                payeeName: nil,
                documentStatus: .complete,
                paymentOperationDetailId: 0)))
    }
}
