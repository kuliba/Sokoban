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
        
        MainSectionCollapsableView(title: viewModel.title,
                                   edges: .all,
                                   isEnabled: viewModel.isEnabled,
                                   isCollapsed: $viewModel.isCollapsed) {

            ForEach(viewModel.items) { model in

                MyProductsSectionItemView(viewModel: model)
            }
        }
    }
}

struct MyProductsSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        MyProductsSectionView(viewModel: .sample1)
    }
}
