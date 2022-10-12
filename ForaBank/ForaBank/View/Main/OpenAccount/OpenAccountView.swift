//
//  OpenAccountView.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 31.05.2022.
//

import SwiftUI
import Shimmer

// MARK: - View

struct OpenAccountView: View {

    @ObservedObject var viewModel: OpenAccountViewModel

    var body: some View {

        VStack(spacing: 0) {

            ZStack {
                
                if viewModel.items.isEmpty == false {
                    
                    PagerScrollView(viewModel: viewModel.pagerViewModel) {
                        ForEach(viewModel.items) { item in
                            OpenAccountItemView(viewModel: item)
                        }
                    }
                    
                } else {

                    Color.mainColorsGrayMedium
                        .opacity(0.5)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shimmering(active: true, bounce: true)
                        .padding(.horizontal, 20)
                }
            }
            .frame(height: viewModel.heightContent)
            .padding(.top, 4)

            OpenAccountPerformView(
                viewModel: .init(
                    model: viewModel.model,
                    item: viewModel.item,
                    currency: viewModel.currency,
                    style: viewModel.style) {
                        viewModel.closeAction()
                    })
            .padding(.bottom, 4)
        }
    }
}

// MARK: - Previews

struct OpenAccountView_Previews: PreviewProvider {
    static var previews: some View {
        OpenAccountView(viewModel: .sample)
            .frame(height: 474)
            .previewLayout(.sizeThatFits)
    }
}
