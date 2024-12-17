//
//  MyProductsTotalMoneyView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//  Full refactored by Dmitry Martynov on 20.08.2022
//

import SwiftUI
import UIPrimitives

struct MyProductsMoneyView: View {
    
    @ObservedObject var viewModel: MyProductsMoneyViewModel
    
    var body: some View {

        VStack(alignment: .trailing, spacing: 4) {
        
            switch viewModel.balanceVM {
            case .placeholder:
                            
                HStack {
                            
                    Text(viewModel.allMoneyTitle)
                        .font(.textH2Sb20282())
                        .foregroundColor(.mainColorsBlack)
                        .lineLimit(1)
                        .layoutPriority(1)
                        
                    GeometryReader { geo in
                       Group {
                           
                           RoundedRectangle(cornerRadius: 90)
                               .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                               .frame(width: 2.3 * geo.size.width / 3)
                               .shimmering(bounce: true)
                           
                        }.frame(width: geo.size.width, alignment: .trailing)
                    }.frame(height: 24)
                        
                        CurrencyButtonView(viewModel: viewModel.currencyButtonVM)
                }
                            
            case let .balanceTitle(balanceStr):
                            
                if viewModel.balanceVM.isSingleLineView {
                            
                    HStack {
                            
                        Text(viewModel.allMoneyTitle)
                                
                        Spacer()
                                
                        Text(balanceStr)
                            .accessibilityIdentifier("AllMoneyAmount")
                                    
                        CurrencyButtonView(viewModel: viewModel.currencyButtonVM)
                    }
                    .font(.textH2Sb20282())
                    .foregroundColor(.mainColorsBlack)
                            
                }  else {
                               
                    VStack(alignment: .leading, spacing: 4) {
                                
                        Text(viewModel.allMoneyTitle)
                            .font(.textH2Sb20282())
                            .foregroundColor(.mainColorsBlack)
                                
                        HStack {
                                        
                            Text(balanceStr)
                                .font(.textH2Sb20282())
                                .foregroundColor(.mainColorsBlack)
                                        
                            Spacer()
                                        
                            CurrencyButtonView(viewModel: viewModel.currencyButtonVM)
                        }
                    }
                }
            }
                   
            Text(viewModel.cbRateTitle)
                .font(.textBodySR12160())
                .foregroundColor(.mainColorsGray)
                .zIndex(-1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .onAppear {
            viewModel.action.send(MyProductsMoneyViewModelAction.ViewDidApear())
        }

    }
}

extension MyProductsMoneyView {

    struct CurrencyButtonView: View {

        @ObservedObject var viewModel: MyProductsMoneyViewModel.CurrencyButtonViewModel

        var body: some View {
            
            Button {
                
                viewModel.action.send(CurrencyButtonViewModelAction.ButtonTapped())
            
            } label: {
            
                ZStack {
                        
                    RoundedRectangle(cornerRadius: 90)
                        .frame(width: 40, height: 24)
                        .foregroundColor(viewModel.state.isDisable
                                            ? .mainColorsGrayMedium.opacity(0.4)
                                            : .mainColorsBlack)
                        .shimmering(active: viewModel.state.isDisable, bounce: true)
                        .accessibilityIdentifier("AllMoneyContainer")
        
                    HStack(spacing: 1) {
                        
                        Text(viewModel.currencySymbol)
                            .font(.textBodyMM14200())
                            .accessibilityIdentifier("AllMoneyCurrency")
                            
                        Image.ic16ChevronDown
            
                    }.foregroundColor(.mainColorsWhite)
                }
            }
            .disabled(viewModel.state.isDisable)
            .overlay13 {
                
                if case let .expanded(currencyItemsVM) = viewModel.state {
    
                    ZStack(alignment: .leading) {
                       
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.mainColorsWhite)
                            .shadow(color: .mainColorsGrayMedium, radius: 3, x: 0, y: 3)
                    
                        ScrollView(showsIndicators: true) {
                            
                            VStack(alignment: .leading, spacing: 2) {
                    
                                ForEach(currencyItemsVM) { item in
                        
                                    Button {
                                        item.action()
                                    } label: {
                            
                                        HStack {
                                
                                            Text(item.symbol)
                                                .font(.textBodyMM14200())
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.mainColorsWhite)
                                                .accessibilityIdentifier("AllMoneyCurrencyLogo")
                                                .background(Circle()
                                                    .foregroundColor(.mainColorsBlack)
                                                    .accessibilityIdentifier("AllMoneyCurrencyLogoBackground"))
                                            
                                            VStack(alignment: .leading, spacing: 1) {
                                                
                                                HStack {
                                                
                                                    Text(item.name)
                                                    .font(.textBodyMM14200())
                                                    
                                                    Spacer()
                                                    
                                                    if item.isSelected { Image.ic16Check }
                                                }
                                
                                                Text(item.rateFormatted)
                                                    .foregroundColor(.textPlaceholder)
                                                    .font(.textBodySR12160())
                                                
                                            }.padding(.top, 4)
                                        }
                                    }.foregroundColor(.mainColorsBlack)
                                    .frame(height: 36)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 11)
                        
                                } //ForEach
                            }
                            
                        } //Scroll
                    }
                    .frame(width: 240,
                           height: currencyItemsVM.count < 6 ? CGFloat(currencyItemsVM.count * 54) : 296)
                    .accessibilityIdentifier("AllMoneyCurrencyMenu")
                    .offset(x: -100,
                            y: currencyItemsVM.count < 6 ? (CGFloat(currencyItemsVM.count * 54 / 2) + 18 ) : 166 )
                    
                }
            }
        }
        
    }
}

struct MyProductsTotalMoneyView_Previews: PreviewProvider {
    static var previews: some View {

        Group {

            MyProductsMoneyView(viewModel: .sampleBalance)
                .previewDevice("iPhone SE (1st generation)")
                .previewLayout(.fixed(width: 350, height: 200))
            
            MyProductsMoneyView(viewModel: .sampleExpanded)
                .previewDevice("iPhone 13 Pro Max")
                .previewLayout(.fixed(width: 400, height: 600))
                
            MyProductsMoneyView(viewModel: .samplePlaceholder)
                .previewDevice("iPhone SE (1st generation)")
                .previewLayout(.sizeThatFits)
        }
    }
}
