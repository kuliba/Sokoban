//
//  MyProductsSectionView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.04.2022.
//

import SwiftUI

struct MyProductsSectionView: View {
    
    @ObservedObject var viewModel: MyProductsSectionViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title,
                               edges: [.leading, .top],
                               padding: 20,
                               isEnabled: viewModel.isEnabled,
                               isCollapsed: $viewModel.isCollapsed) {

            ForEach(viewModel.items) { model in

                switch model {
                    
                case let productModel as MyProductsSectionProductItemViewModel:
                    MyProductsSectionItemView(viewModel: productModel)
                        .padding(.top, (viewModel.padding(productModel)))
                    
                case let buttonModel as MyProductsSectionButtonItemViewModel:
                    MyProductsSectionButtonItemView(viewModel: buttonModel)
                        .padding(.top, (viewModel.padding(buttonModel)))
                    
                default:
                    EmptyView()
                }
                
                
            }
        }
    }
}

struct MyProductsSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        MyProductsSectionView(viewModel: .sample1)
            .previewLayout(.sizeThatFits)
    }
}
