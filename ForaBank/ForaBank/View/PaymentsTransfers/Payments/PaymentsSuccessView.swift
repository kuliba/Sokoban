//
//  PaymentsSuccessView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI

struct PaymentsSuccessView: View {
    
    @ObservedObject var viewModel: PaymentsSuccessViewModel
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                scrollContent()
                
                bottom()
                    .padding(.bottom, 24)
            }
            
            viewModel.spinner.map(SpinnerView.init(viewModel:))
        }
        .alert(item: $viewModel.alert, content: Alert.init(with:))
        .fullScreenCover(item: $viewModel.fullScreenCover, content: fullScreenCoverContent)
        .sheet(item: $viewModel.sheet, content: sheetContent)
    }
    
    private func scrollContent() -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 24) {
                
                ForEach(viewModel.feed, content: PaymentsGroupView.groupView(for:))
            }
            .padding(.bottom, 56)
        }
    }
    
    private func bottom() -> some View {
        
        VStack(spacing: 0) {
            
            ForEach(viewModel.bottom, content: PaymentsGroupView.groupView(for:))
        }
    }
    
    @ViewBuilder
    private func fullScreenCoverContent(
        cover: PaymentsSuccessViewModel.FullScreenCover
    ) -> some View {
        
        switch cover.type {
        case let .abroad(paymentsViewModel):
            PaymentsView(viewModel: paymentsViewModel)
            
        case let .success(successViewModel):
            PaymentsSuccessView(viewModel: successViewModel)
        }
    }
    
    @ViewBuilder
    private func sheetContent(
        sheet: PaymentsSuccessViewModel.Sheet
    ) -> some View {
        
        switch sheet.type {
        case let .printForm(printFormViewModel):
            PrintFormView(viewModel: printFormViewModel)
            
        case let .detailInfo(detailInfoViewModel):
            OperationDetailInfoView(viewModel: detailInfoViewModel)
        }
    }
}

struct PaymentsSuccessView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            Group {
                
                PaymentsSuccessView(viewModel: .sampleSuccess)
                PaymentsSuccessView(viewModel: .sampleC2BSub)
                PaymentsSuccessView(viewModel: .sampleC2B)
            }
            
            Group {
                
                PaymentsSuccessView(viewModel: .sample1)
                PaymentsSuccessView(viewModel: .sample2)
                PaymentsSuccessView(viewModel: .sample3)
                PaymentsSuccessView(viewModel: .sample4)
                PaymentsSuccessView(viewModel: .sample5)
                PaymentsSuccessView(viewModel: .sample6)
                PaymentsSuccessView(viewModel: .sample7)
                PaymentsSuccessView(viewModel: .sample8)
                PaymentsSuccessView(viewModel: .sample9)
                PaymentsSuccessView(viewModel: .sample10)
            }
        }
    }
}

//MARK: - Preview Content

extension PaymentsSuccessViewModel {
    
    static let sampleSuccess = PaymentsSuccessViewModel(sections: [
        PaymentsSectionViewModel(
            placement: .feed,
            groups: [
                .init(items: [PaymentsSuccessStatusView.ViewModel.sampleSuccess]),
                .init(items: [PaymentsSuccessTextView.ViewModel.sampleTitle]),
                .init(items: [PaymentsSuccessTextView.ViewModel.sampleAmount]),
                .init(items: [PaymentsSuccessIconView.ViewModel.sampleImage]),
                .init(items: [PaymentsSuccessOptionButtonsView.ViewModel.sample]),
            ]),
        PaymentsSectionViewModel(
            placement: .bottom,
            groups: [
                .init(items: [PaymentsButtonView.ViewModel.sampleParam])
            ])
    ], adapter: .init(model: .emptyMock), operation: nil)
    
    static let sampleC2BSub = PaymentsSuccessViewModel(sections: [
        PaymentsSectionViewModel(
            placement: .feed,
            groups: [
                .init(items: [PaymentsSuccessStatusView.ViewModel.sampleSuccess]),
                .init(items: [PaymentsSuccessTextView.ViewModel.sampleC2BSub]),
                .init(items: [PaymentsSubscriberView.ViewModel.sampleC2BSub]),
                .init(items: [PaymentsSuccessLinkView.ViewModel.sample])
            ]),
        PaymentsSectionViewModel(
            placement: .bottom,
            groups: [
                .init(items: [PaymentsButtonView.ViewModel.sampleParam]),
                .init(items: [PaymentsSuccessIconView.ViewModel.sampleName])
            ])
    ], adapter: .init(model: .emptyMock), operation: nil)
    
    static let sampleC2B = PaymentsSuccessViewModel(sections: [
        PaymentsSectionViewModel(
            placement: .feed,
            groups: [
                .init(items: [PaymentsSuccessStatusView.ViewModel.sampleSuccess]),
                .init(items: [PaymentsSuccessTextView.ViewModel.sampleC2B]),
                .init(items: [PaymentsSuccessTextView.ViewModel.sampleAmount]),
                .init(items: [PaymentsSubscriberView.ViewModel.sampleC2B]),
                .init(items: [PaymentsSuccessLinkView.ViewModel.sample]),
                .init(items: [PaymentsProductView.ViewModel.sample]),
                .init(items: [PaymentsSuccessTextView.ViewModel.sampleMessage]),
                .init(items: [PaymentsSuccessOptionButtonsView.ViewModel.sampleC2B])
            ]),
        PaymentsSectionViewModel(
            placement: .bottom,
            groups: [
                .init(items: [PaymentsButtonView.ViewModel.sampleParam]),
                .init(items: [PaymentsSuccessIconView.ViewModel.sampleName])
            ])
    ], adapter: .init(model: .emptyMock), operation: nil)
}
