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
            .navigationBarTitle(Text(viewModel.navigationBar.title), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: BackButtonView(viewModel: viewModel),
                trailing: AddButtonView(viewModel: viewModel)
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

    struct BackButtonView: View {

        let viewModel: MyProductsViewModel

        var body: some View {

            Button {

                viewModel.action.send(MyProductsNavigationItemAction.Back())

            } label: {

                viewModel.navigationBar.backButton.icon
                    .foregroundColor(.mainColorsBlack)
            }
        }
    }

    struct AddButtonView: View {

        let viewModel: MyProductsViewModel

        var body: some View {

            Button {

                viewModel.action.send(MyProductsNavigationItemAction.Add())

            } label: {

                viewModel.navigationBar.addButton.icon
                    .foregroundColor(.mainColorsGray)
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
