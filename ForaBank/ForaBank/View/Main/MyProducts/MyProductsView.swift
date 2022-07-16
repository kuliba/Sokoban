//
//  MyProductsView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//

import Foundation
import SwiftUI

//MARK: - View

struct MyProductsView: View {
    
    @ObservedObject var viewModel: MyProductsViewModel
    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                MyProductsMoneyView(viewModel: viewModel.totalMoney)
                
                ScrollView {
                    
                    ForEach(viewModel.sections) { model in
                        
                        MyProductsSectionView(viewModel: model)
                    }
                }
                .background(Color.mainColorsWhite)
                .padding(.top, -5)
            }
            .navigationBar(with: viewModel.navigationBar)
            
            if let viewModel = viewModel.currencyMenu {
                
                ZStack(alignment: .topTrailing) {
                    
                    Color.clear
                    
                    MyProductsCurrencyMenuView(viewModel: viewModel)
                        .frame(width: 239, height: 222)
                        .padding(.top, 42)
                        .padding(.trailing, 19)
                }
            }
            NavigationLink("", isActive: $viewModel.isLinkActive) {
                
                if let link = viewModel.link  {
                    
                    switch link {
                        
                    case .productProfile(let productProfileViewModel):
                        ProductProfileView(viewModel: productProfileViewModel)
                    }
                }
            }
        }
    }
}

//MARK: - Preview

struct AllMoneyView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            MyProductsView(viewModel: .sample)
        }
    }
}
