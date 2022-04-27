//
//  MyProductsView.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 08.03.2022.
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
            .navigationBarTitle(Text(viewModel.navigationBar.title).font(.textH3M18240()),
                                displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: NavigationItemView(viewModel: viewModel.navigationBar.backButton),
                trailing: NavigationItemView(viewModel: viewModel.navigationBar.addButton)
            )
            
            if let viewModel = viewModel.currencyMenu {
                
                ZStack(alignment: .topTrailing) {
                    
                    Color.clear
                    
                    MyProductsCurrencyMenuView(viewModel: viewModel)
                        .frame(width: 239, height: 222)
                        .padding(.top, 42)
                        .padding(.trailing, 19)
                }
            }
        }
    }
}

extension MyProductsView {
    
    struct NavigationItemView: View {
        
        let viewModel: MyProductsViewModel.NavigationButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                viewModel.icon
            }
        }
    }
}

//MARK: - Preview

struct AllMoneyView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            MyProductsView(viewModel: .sample)
        }.padding(.top)
    }
}
