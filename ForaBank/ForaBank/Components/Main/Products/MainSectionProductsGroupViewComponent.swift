//
//  MainSectionProductsGroupViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 18.05.2022.
//

import Foundation
import SwiftUI

extension MainSectionProductsGroupView {
    
    class ViewModel: MainSectionProductsListItemViewModel, ObservableObject {
        
        @Published var hiddenItemsCount: String
        @Published var isCollapsed: Bool

        init(hiddenItemsCount: String, isCollapsed: Bool = true) {
            
            self.hiddenItemsCount = hiddenItemsCount
            self.isCollapsed = isCollapsed
            super.init()
        }
    }
}

struct MainSectionProductsGroupView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)
            
            if viewModel.isCollapsed {
                
                Text("+\(viewModel.hiddenItemsCount)")
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
            } else {
                
                Image.ic24ChevronsLeft
                    .foregroundColor(.iconBlack)
            }
        }
        .frame(width: 48)
    }
}

//MARK: - Preview

struct MainSectionProductsGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MainSectionProductsGroupView(viewModel: .sampleCollapsed)
                .previewLayout(.fixed(width: 375, height: 200))
            
            MainSectionProductsGroupView(viewModel: .sampleExpanded)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension MainSectionProductsGroupView.ViewModel {
    
    static let sampleCollapsed = MainSectionProductsGroupView.ViewModel(hiddenItemsCount: "5", isCollapsed: true)
    
    static let sampleExpanded = MainSectionProductsGroupView.ViewModel(hiddenItemsCount: "5", isCollapsed: false)
}
