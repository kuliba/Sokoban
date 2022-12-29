//
//  SbpPayView.swift
//  ForaBank
//
//  Created by Дмитрий on 29.08.2022.
//

import SwiftUI

struct SbpPayView: View {
    
    @ObservedObject var viewModel: SbpPayViewModel
    
    var body: some View {
         
            VStack {
                
                HeaderView(viewModel: viewModel.header)
                    .padding(.bottom, 40)

                if let productsViewModel = viewModel.paymentProduct {

                    ProductSelectorView(viewModel: productsViewModel)
                }
        
                Divider()
                    .padding(.leading, 68)
                    .padding(.trailing, 8)
                    .padding(.bottom, 24)
                
                ConditionsView(viewModel: viewModel.conditions)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(12)
                    .padding(.bottom, 32)
                
                FooterView(viewModel: viewModel.footer)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 12)
            .padding(.top, 20)
            .padding(.bottom, 30)
    }
}

extension SbpPayView {
    
    struct HeaderView: View {
        
        let viewModel: SbpPayViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                ZStack {
                    
                    Circle()
                        .frame(width: 64, height: 64, alignment: .center)
                        .foregroundColor(.mainColorsGrayLightest)
                    
                    viewModel.image
                        .renderingMode(.original)
                    
                }
                
                Text(viewModel.title)
                    .font(.textH4SB16240())
            }
        }
    }
    
    struct ConditionsView: View {
        
        let viewModel: [SbpPayViewModel.ConditionViewModel]
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 16) {
                
                ForEach(viewModel, id: \.self) { condition in
                    
                    Link(destination: condition.link) {
                        
                        HStack(alignment: .top, spacing: 24) {
                            
                            condition.image
                                .foregroundColor(.iconGray)
                            
                            Text(condition.title)
                                .foregroundColor(.mainColorsBlack)
                                .multilineTextAlignment(.leading)
                                .font(.textBodyMR14200())
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    struct FooterView: View {
        
        let viewModel: SbpPayViewModel.FooterViewModel
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                switch viewModel.state {
                case .spinner:
                    SpinnerRefreshView(icon: viewModel.spinnerIcon)
                        .frame(height: 48)
                    
                case let .button(viewModel):
                    ButtonSimpleView(viewModel: viewModel)
                        .frame(height: 48)
                }
                
                HStack {
                    
                    Text(viewModel.descriptionButton)
                        .multilineTextAlignment(.leading)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                    
                    Spacer()
                }
            }
        }
    }
}

struct SbpPayView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        SbpPayView(viewModel: .init(.emptyMock, paymentProduct: .sampleMe2MeCollapsed, conditions: [.init(title: "Условия обслуживания при использовании СБП", link: .init(string: "")!), .init(title: "Соглашения/Договор на использование СБПэй", link: .init(string: "")!)], rootActions: nil))
    }
}
