//
//  ProductProfileDetaiHeaderViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 16.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
    
    class HeaderViewModel: ObservableObject {

        let title: String
        @Published var isCollapsed: Bool
        let action: () -> Void
        
        internal init(title: String = "Детали счета", isCollapsed: Bool = false, action: @escaping () -> Void) {
            
            self.title = title
            self.isCollapsed = isCollapsed
            self.action = action
        }
    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct HeaderView: View {
        
        @ObservedObject var viewModel: ProductProfileDetailView.ViewModel.HeaderViewModel
        
        var body: some View {
            
            HStack {
                
                Text(viewModel.title)
                    .font(.textH2Sb20282())
                    .foregroundColor(.textWhite)
                
                Spacer()
                
                Image.ic24ChevronDown
                    .foregroundColor(.iconGray)
                    .rotationEffect(Angle(degrees: viewModel.isCollapsed ? 0 : -180))
            }
            .onTapGesture {
                
                viewModel.action()
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetaiHeaderViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileDetailView.HeaderView(viewModel: .sampleExpanded)
                .background(Color.black)
                .previewLayout(.fixed(width: 375, height: 60))
            
            ProductProfileDetailView.HeaderView(viewModel: .sampleCollapsed)
                .background(Color.black)
                .previewLayout(.fixed(width: 375, height: 60))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.HeaderViewModel {
    
    static let sampleExpanded = ProductProfileDetailView.ViewModel.HeaderViewModel(title: "Детали счета", isCollapsed: false, action: {})
    
    static let sampleCollapsed = ProductProfileDetailView.ViewModel.HeaderViewModel(title: "Детали счета", isCollapsed: true, action: {})
}
