//
//  MainSectionOpenProductViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainSectionOpenProductView {
    
    class ViewModel: MainSectionCollapsableViewModel {

        override var type: MainSectionType { .openProduct }
        let items: [ButtonNewProduct.ViewModel]

        internal init(items: [ButtonNewProduct.ViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
    }
}

//MARK: - View

struct MainSectionOpenProductView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {
                    
                    ForEach(viewModel.items) { itemViewModel in
                        
                        ButtonNewProduct(viewModel: itemViewModel)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
//MARK: - Preview

struct MainBlockOpenProductsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionOpenProductView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionOpenProductView.ViewModel {

    static let sample = MainSectionOpenProductView.ViewModel(items: [.sample, .sample, .sample,.sample], isCollapsed: false)
}
