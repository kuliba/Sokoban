//
//  OpenDepositListView.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import SwiftUI
import ScrollViewProxy

struct OpenDepositListView: View {
    
    @ObservedObject var viewModel: OpenDepositListViewModel
    let getUImage: (Md5hash) -> UIImage?
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                ForEach(viewModel.offers, content: offerProductView)
            }
            .foregroundColor(.black)
            .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
                
                switch bottomSheet.type {
                case let .openDeposit(additionalCondition):
                    OfferProductView.DetailConditionView(viewModel: additionalCondition)
                }
            }
        }
        .navigationBarTitle(viewModel.navigationBar.title, displayMode: .inline)
        .ignoresSafeArea()
        .navigationBar(with: viewModel.navigationBar)
        .navigationDestination(
            item: .init(
                get: { viewModel.route.destination },
                set: { if $0 == nil { viewModel.resetDestination() }}
            ),
            content: destinationView
        )
    }
    
    private func offerProductView(
        offer: OfferProductView.ViewModel
    ) -> some View {
        
        OfferProductView(viewModel: offer)
    }
    
    @ViewBuilder
    private func destinationView(
        destination: OpenDepositListViewModel.Route.Link
    ) -> some View {
        
        switch destination {
        case let .openDeposit(viewModel):
            OpenDepositDetailView(viewModel: viewModel, getUImage: getUImage)
        }
    }
}

struct OpenDepositView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OpenDepositListView(
            viewModel: .init(
                navigationBar: .init(title: "Вклады"),
                products: [.depositSample, .depositSample],
                catalogType: .deposit, 
                makeAlertViewModel: { .disableForCorporateCard(primaryAction: $0) }
            ),
            getUImage: { _ in nil }
        )
    }
}
