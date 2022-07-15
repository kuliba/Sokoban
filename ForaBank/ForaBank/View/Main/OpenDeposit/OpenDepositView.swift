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
                    
                        OfferProductView(viewModel: productCard)

                }
            }
            .navigationBarTitle(Text("Вклады"), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button(action: viewModel.navButtonBack.action, label: {
                    viewModel.navButtonBack.icon
                        .renderingMode(.template)
                        .foregroundColor(.iconBlack)
                }))
            .foregroundColor(.black)
            .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
                
                switch bottomSheet.type {
                case let .openDeposit(additionalCondition):
                    OfferProductView.DetailConditionView(viewModel: additionalCondition)
                }
            }
        }
    }
}

struct OpenDepositView_Previews: PreviewProvider {
    
    static var previews: some View {
        OpenDepositView(viewModel: .init(navButtonBack: .init(icon: .ic24ChevronLeft, action: {}), products: [.depositSample, .depositSample],  catalogType: .deposit))
    }
}
