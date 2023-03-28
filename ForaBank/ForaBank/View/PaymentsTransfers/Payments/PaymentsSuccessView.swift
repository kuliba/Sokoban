//
//  PaymentsSuccessView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI

struct PaymentsSuccessView: View {
    
    @ObservedObject var viewModel: PaymentsSuccessViewModel
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 24) {
            
            Group {
                
                Spacer()
                
                StateIconView(viewModel: viewModel.iconType)
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
                
                if let company = viewModel.company {
                    
                    CompanyView(viewModel: company)
                }
                
                if let link = viewModel.link {
                    
                    LinkView(viewModel: link)
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
                
                VStack(spacing: 20) {
                    
                    ButtonSimpleView(viewModel: viewModel.actionButton)
                        .frame(height: 48)
                        .padding(.horizontal, 20)
                    
                    if let bottomIcon = viewModel.bottomIcon {
                        
                        bottomIcon
                            .renderingMode(.original)
                    }
                    
                }.padding(.bottom, bottomPadding)
            }
        }
        .background(Color.mainColorsWhite)
        .sheet(item: $viewModel.sheet) { sheet in

            switch sheet.type {
            case let .printForm(printViewModel):
                PrintFormView(viewModel: printViewModel)

            case let .detailInfo(detailViewModel):
                OperationDetailInfoView(viewModel: detailViewModel)
            }
        }
    }
}

extension PaymentsSuccessView {
    
    var bottomPadding: CGFloat {
        
        UIApplication.safeAreaInsets.bottom == 0 ? 20 : 0
    }
    
    // MARK: - Icon
    
    struct StateIconView: View {
        
        let viewModel: PaymentsSuccessViewModel.IconTypeViewModel
        
        var body: some View {
            
            ZStack {
                
                Circle()
                    .foregroundColor(viewModel.color)
                
                viewModel.image
                    .foregroundColor(.mainColorsWhite)
                
            }.frame(width: 88, height: 88)
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
    
    struct CompanyView: View {
        
        let viewModel: PaymentsSuccessViewModel.Company
        
        var body: some View {
            
            VStack {
                
                viewModel.icon
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Text(viewModel.name)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    struct LinkView: View {
        
        let viewModel: PaymentsSuccessViewModel.Link
        @Environment(\.openURL) var openURL
        
        var body: some View {
            
            HStack(spacing: 10) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.mainColorsGray)
                
                Text(viewModel.title)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textSecondary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsGrayLightest))
            .onTapGesture {
                
                openURL(viewModel.url)
            }
        }
    }
}

struct PaymentsSuccessView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {
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
                PaymentsSuccessView(viewModel: .sample10)
            }

            // Mobile Connection Payments
            
            Group {
                
                PaymentsSuccessView(viewModel: .previewMobileConnectionOk)
                PaymentsSuccessView(viewModel: .previewMobileConnectionAccepted)
                PaymentsSuccessView(viewModel: .previewMobileConnectionFailed)
            }
            .previewDisplayName("Mobile Connection Payment")
        }
    }
}
