//
//  MyProductsTotalMoneyView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//

import SwiftUI

struct MyProductsMoneyView: View {
    
    @ObservedObject var viewModel: MyProductsMoneyViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack() {
                
                Color.barsTabbar
                
                VStack(spacing: 0) {
                    
                    HStack {
                        
                        Text(viewModel.title)
                            .padding(.leading, 20)
                            .font(.textH2SB20282())
                        
                        Spacer()
                        
                        Text(viewModel.balance)
                            .padding(.trailing, 7)
                            .font(.textH2SB20282())

                        MyProductsMoneyViewButton(viewModel: viewModel.currencyButton)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 4)
                    
                    HStack {
                        
                        Spacer()
                        
                        Text(viewModel.subtitle)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                            .padding(.trailing, 19)
                    }
                    .padding(.bottom, 12)
                }
            }
            .frame(height: 76)
            .padding(.bottom, 16)
        }
    }
}

extension MyProductsMoneyView {

    struct MyProductsMoneyViewButton: View {

        @ObservedObject var viewModel: MyProductsMoneyViewModel.CurrencyButtonViewModel

        private var foregroundColor: Color {

            if viewModel.isSelected {
                return .mainColorsBlack
            }

            return .buttonPrimaryDisabled
        }

        var body: some View {

            Button {

                viewModel.isSelected.toggle()

            } label: {

                ZStack {

                    HStack {

                        Capsule()
                            .foregroundColor(foregroundColor)

                    }.frame(width: 40, height: 24)

                    HStack(spacing: 3) {

                        Text(viewModel.title)
                            .foregroundColor(.textWhite)

                        viewModel.icon
                            .foregroundColor(.iconWhite)

                    }.padding(.vertical, 4)
                }
            }.padding(.trailing, 19)
        }
    }
}

struct MyProductsTotalMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        MyProductsMoneyView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
    }
}
