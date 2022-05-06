//
//  DepositBottomSheetView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import SwiftUI

struct DepositBottomSheetView: View {
    
    @ObservedObject var viewModel: DepositBottomSheetViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text(viewModel.title)
                .font(.textH3SB18240())
                .padding(.bottom, 8)
            
            ForEach(viewModel.items) { item in
                
                DepositBottomSheetItemView(viewModel: item)
                    .onTapGesture {

                        viewModel.viewModel = .init(
                            term: item.term,
                            rate: item.rate,
                            termName: item.termName
                        )

                        viewModel.isShowBottomSheet = false
                    }
            }
        }
        .padding(.bottom)
        .padding([.leading, .trailing], 20)
    }
}

struct DepositBottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DepositBottomSheetView(
            viewModel: .init(
                title: "Срок вклада",
                items: [
                    .init(term: 365, rate: 8.25, termName: "1 год"),
                    .init(term: 540, rate: 13.06, termName: "1 год 6 месяцев")
                ],
                viewModel: .init(term: 365, rate: 8.25, termName: "1 год")))
            .previewLayout(.sizeThatFits)
    }
}
