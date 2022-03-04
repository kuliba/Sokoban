//
//  MainBlockOpenProductsViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainBlockOpenProductsView {
    
    class ViewModel: MainSectionCollapsableViewModel {

        let items: [ButtonNewProduct.ViewModel]
        let title: String
        
        internal init(items: [ButtonNewProduct.ViewModel], title: String, isCollapsed: Bool) {
            self.items = items
            self.title = title

            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct MainBlockOpenProductsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack {
            
            Button {

                viewModel.isCollapsed.toggle()

            } label: {

                HStack {

                    Text(viewModel.title)
                        .font(.textH2SB20282())
                        .foregroundColor(.textSecondary)

                    if viewModel.isCollapsed {
                        Image.ic24ChevronUp
                            .foregroundColor(.iconGray)
                    } else {
                        Image.ic24ChevronDown
                            .foregroundColor(.iconGray)
                    }

                    Spacer()
                }
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)

            if !viewModel.isCollapsed {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.items) { itemViewModel in
                            ButtonNewProduct(viewModel: itemViewModel)
                        }
                    }
                }
                .frame(height: 96)
            }
        }
    }
}
//MARK: - Preview

struct MainBlockOpenProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainBlockOpenProductsView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension MainBlockOpenProductsView.ViewModel {

    static let sample = MainBlockOpenProductsView.ViewModel(items: [.sample,
                                                                    .sample,
                                                                    .sample,
                                                                    .sample],
                                                            title: "Открыть продукт",
                                                            isCollapsed: false)
}
