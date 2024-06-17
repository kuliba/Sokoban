//
//  PaymentsSuccessView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI

struct PaymentsSuccessView: View {
    
    @ObservedObject var viewModel: PaymentsSuccessViewModel
    
    var spacing: CGFloat = 24
    var bottomPadding: CGFloat = 56
    
    @State private var totalItemHeights: CGFloat = .zero
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                scrollContent()
                
                bottom()
                    .padding(.bottom, 24)
            }
            
            viewModel.informer.map(informerView)
            
            viewModel.spinner.map(SpinnerView.init(viewModel:))
        }
        .alert(
            item: $viewModel.alert,
            content: Alert.init(with:)
        )
        .fullScreenCover(
            item: $viewModel.fullScreenCover,
            content: fullScreenCoverContent
        )
        .sheet(
            item: $viewModel.sheet,
            content: sheetContent
        )
    }
    
    private func scrollContent() -> some View {
        
        GeometryReader { proxy in
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: spacing) {
                    
                    ForEach(viewModel.feed) { groupView($0, proxy.size.height) }
                }
                .onPreferenceChange(HeightsPreferenceKey.self, perform: setTotalItemHeights)
                .frame(maxWidth: .infinity)
                .padding(.bottom, bottomPadding)
            }
        }
    }
    
    @ViewBuilder
    private func groupView(
        _ viewModel: PaymentsGroupViewModel,
        _ height: CGFloat
    ) -> some View {
        
        ForEach(viewModel.items) { itemViewModel in
            
            let isTheItem = itemViewModel is PaymentsSuccessOptionButtonsView.ViewModel
            
            PaymentsGroupView.separatedItemView(
                for: itemViewModel,
                items: viewModel.items
            )
            .reportHeight()
            .padding(.top, isTheItem ? extraTopPadding(for: height) : 0)
        }
    }
    
    private func setTotalItemHeights(to totalItemHeights: CGFloat) {
        
        DispatchQueue.main.async {
            
            self.totalItemHeights = totalItemHeights
        }
    }
    
    private func extraTopPadding(
        for height: CGFloat
    ) -> CGFloat {
        
        let totalSpacingHeight = spacing * CGFloat(viewModel.feed.count - 1)
        let totalContentHeight = totalItemHeights + totalSpacingHeight
        let availableHeight = height - bottomPadding
        let requiredPadding = availableHeight - totalContentHeight
        
        return max(0, requiredPadding)
    }
    
    private func bottom() -> some View {
        
        VStack(spacing: 0) {
            
            ForEach(viewModel.bottom, content: PaymentsGroupView.groupView)
        }
    }
    
    private func informerView(
        informer: PaymentsSuccessViewModel.Informer
    ) -> some View {
        
        InformerInternalView(
            message: informer.message,
            icon: .ic24Copy,
            color: .mainColorsBlackMedium
        )
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 108)
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

private struct HeightsPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(
        value: inout CGFloat,
        nextValue: () -> CGFloat
    ) {
        value += nextValue()
    }
}

private extension View {
    
    func reportHeight() -> some View {
        
        self.background(
            GeometryReader { proxy in
                
                Color.clear
                    .preference(
                        key: HeightsPreferenceKey.self,
                        value: proxy.size.height
                    )
            }
        )
    }
}

struct PaymentsSuccessView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            Group {
                
                PaymentsSuccessView(viewModel: .sampleSuccess)
                    .previewDisplayName("sampleSuccess")
                PaymentsSuccessView(viewModel: .sampleC2BSub)
                    .previewDisplayName("sampleC2BSub")
                PaymentsSuccessView(viewModel: .sampleC2B)
                    .previewDisplayName("sampleC2B")
            }
            
            Group {
                
                PaymentsSuccessView(viewModel: .sample1)
                    .previewDisplayName("1: Успешный перевод")
                PaymentsSuccessView(viewModel: .sample2)
                    .previewDisplayName("2: принят в обработку")
                PaymentsSuccessView(viewModel: .sample3)
                    .previewDisplayName("3: Операция неуспешна!")
                PaymentsSuccessView(viewModel: .sample4)
                    .previewDisplayName("4: принят в обработку")
                PaymentsSuccessView(viewModel: .sample5)
                    .previewDisplayName("5: Операция в обработке!")
                PaymentsSuccessView(viewModel: .sample6)
                    .previewDisplayName("6: Перевод отменен!")
                PaymentsSuccessView(viewModel: .sample7)
                    .previewDisplayName("7: Перевод отменен!")
                PaymentsSuccessView(viewModel: .sample8)
                    .previewDisplayName("8: Из банка:")
                PaymentsSuccessView(viewModel: .sample9)
                    .previewDisplayName("9: Из банка:")
                PaymentsSuccessView(viewModel: .sample10)
                    .previewDisplayName("10: Привязка счета оформлена")
            }
        }
    }
}

struct PaymentsSuccessView_More_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSuccessView(viewModel: .fraudCancelled(
                goToMain: { print("Go to Main") }
            ))
            .previewDisplayName("Fraud: Cancelled")
            
            PaymentsSuccessView(viewModel: .fraudExpired)
                .previewDisplayName("Fraud: Expired")
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
    ], adapter: .preview, operation: nil)
    
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
    ], adapter: .preview, operation: nil)
    
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
    ], adapter: .preview, operation: nil)
}

private extension PaymentsSuccessViewModelAdapter {
    
    static let preview: PaymentsSuccessViewModelAdapter = .init(model: .emptyMock)
}
