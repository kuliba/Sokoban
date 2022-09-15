//
//  PaymentsSuccessView.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI

//MARK: - View

struct PaymentsSuccessView: View {
    
    let viewModel: PaymentsSuccessViewModel
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 24) {
            
            Group {
                
                StateIconView(viewModel: viewModel.iconType)
                    .padding(.top, 132)
            }
            
            Group {
                
                if let warningTitle = viewModel.warningTitle {
                    
                    Text(warningTitle)
                        .font(.textH4M16240())
                        .foregroundColor(.systemColorError)
                        .padding(.horizontal, 20)
                }
                
                if let title = viewModel.title {
                    
                    Text(title)
                        .font(.textH3SB18240())
                        .foregroundColor(.mainColorsBlack)
                        .multilineTextAlignment(.center)
                        .frame(width: 250)
                }
                
                if let service = viewModel.service {
                    ServiceView(viewModel: service)
                }
                
                if let amount = viewModel.amount {
                    
                    Text(amount)
                        .font(.textH1SB24322())
                        .foregroundColor(.mainColorsBlack)
                        .padding(.horizontal, 20)
                }
                
                if let options = viewModel.options {
                    
                    HStack {
                        
                        VStack(alignment: .leading,spacing: 24) {
                            
                            ForEach(options) { viewModel in
                                OptionView(viewModel: viewModel)
                            }
                        }
                        
                        Spacer()
                        
                    }.padding(.horizontal, 20)
                }
                
                if let logoIconViewModel = viewModel.logo {
                    LogoIconView(viewModel: logoIconViewModel)
                }
                
                Spacer()
            }
            
            Group {
                
                HStack(spacing: 52) {
                    
                    ForEach(viewModel.optionButtons) { buttonViewModel in
                        
                        switch buttonViewModel {
                        case let optionButtonViewModel as PaymentsSuccessOptionButtonView.ViewModel:
                            PaymentsSuccessOptionButtonView(viewModel: optionButtonViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
                }.padding(.bottom, 20)
                
                if let repeatButton = viewModel.repeatButton {
                    
                    ButtonSimpleView(viewModel: repeatButton)
                        .frame(height: 48)
                        .padding(.horizontal, 20)
                }
                
                ButtonSimpleView(viewModel: viewModel.actionButton)
                    .frame(height: 48)
                    .padding(.horizontal, 20)
            }
        }
    }
}

extension PaymentsSuccessView {
    
    // MARK: - Icon
    
    struct StateIconView: View {
        
        let viewModel: PaymentsSuccessViewModel.IconTypeViewModel
        
        var body: some View {
            
            ZStack {
                
                viewModel.color
                viewModel.image
                    .foregroundColor(.mainColorsWhite)
                    .frame(width: viewModel.size.width, height: viewModel.size.height)
            }
            .cornerRadius(44)
            .frame(width: 88, height: 88)
        }
    }
    
    // MARK: - Option
    
    struct OptionView: View {
        
        let viewModel: PaymentsSuccessViewModel.OptionViewModel
        
        var body: some View {
            
            HStack(spacing: 14) {
                
                viewModel.image
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsGray)
                    
                    Text(viewModel.description)
                        .font(.textH4M16240())
                        .foregroundColor(.mainColorsBlack)
                    
                    if let subTitle = viewModel.subTitle {
                        
                        Text(subTitle)
                            .font(.textBodyMR14200())
                            .foregroundColor(.mainColorsGray)
                    }
                }
            }
        }
    }
    
    // MARK: - Logo
    
    struct LogoIconView: View {
        
        let viewModel: PaymentsSuccessViewModel.LogoIconViewModel
        
        var body: some View {
            
            HStack(spacing: 0) {
                
                viewModel.image
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 44, height: 44)
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
            }
        }
    }
    
    // MARK: - Service
    
    struct ServiceView: View {
        
        let viewModel: PaymentsSuccessViewModel.ServiceViewModel
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.mainColorsGray)
                
                Text(viewModel.description)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
            }
        }
    }
}

// MARK: - Preview

struct PaymentsSuccessScreenView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSuccessView(viewModel: .sample1)
            PaymentsSuccessView(viewModel: .sample2)
            PaymentsSuccessView(viewModel: .sample3)
            PaymentsSuccessView(viewModel: .sample4)
            PaymentsSuccessView(viewModel: .sample5)
            PaymentsSuccessView(viewModel: .sample6)
            PaymentsSuccessView(viewModel: .sample7)
            PaymentsSuccessView(viewModel: .sample8)
            PaymentsSuccessView(viewModel: .sample9)
        }
    }
}
