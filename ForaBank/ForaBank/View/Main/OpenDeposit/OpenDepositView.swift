//
//  OpenDepositView.swift
//  ForaBank
//
//  Created by Дмитрий on 28.04.2022.
//

import SwiftUI
import ScrollViewProxy

struct OpenDepositView: View {
    
    @ObservedObject var viewModel: OpenDepositViewModel

    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                ForEach(viewModel.products) { productCard in
                    
                    switch viewModel.style {
                    case .deposit:
                        OfferProductView(viewModel: productCard)

                    case .catalog:
                        OfferProductView(viewModel: productCard)
                    }
                }
            }
            .navigationBarTitle(Text("Вклады"), displayMode: .inline)
            .foregroundColor(.black)

            ForEach(viewModel.products) { productCard in
                switch viewModel.style {
                case .deposit:
                    DepositShowBottomSheetView(viewModel: productCard)

                case .catalog:
                    DepositShowBottomSheetView(viewModel: productCard)
                }
            }
        }
    }
    
    struct DepositShowBottomSheetView: View {
        
        @ObservedObject var viewModel: OfferProductView.ViewModel

        var body: some View {

            BottomSheetView(isOpen: $viewModel.isShowSheet, maxHeight: CGFloat((viewModel.additionalCondition?.desc.count ?? 0) * 100)) {
                if let additionalCondition = viewModel.additionalCondition {
                    
                    OfferProductView.DetailConditionView(viewModel: additionalCondition)
                }
            }
            .offset(y: 180)
        }
    }
}

struct OpenDepositView_Previews: PreviewProvider {
    
    static var previews: some View {
        OpenDepositView(viewModel: .init(products: [.depositSample, .depositSample], style: .deposit))
    }
}
