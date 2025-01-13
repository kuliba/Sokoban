//
//  OpenAccountView.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 31.05.2022.
//

import SwiftUI

// MARK: - View

struct OpenAccountView: View {

    @ObservedObject var viewModel: OpenAccountViewModel

    var body: some View {

        VStack(spacing: 0) {

            PagerScrollView(viewModel: viewModel.pagerViewModel) {
                ForEach(viewModel.items) { item in
                    OpenAccountItemView(viewModel: item)
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
