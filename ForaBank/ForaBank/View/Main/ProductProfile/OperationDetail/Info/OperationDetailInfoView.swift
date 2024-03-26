//
//  OperationDetailInfoView.swift
//  ForaBank
//
//  Created by Дмитрий on 27.12.2021.
//

import SwiftUI
import Combine

struct OperationDetailInfoView: View {
    
    let viewModel: OperationDetailInfoViewModel
    
    var body: some View {
        
        OperationDetailInfoInternalView(
            title: viewModel.title,
            logo: viewModel.logo,
            cells: viewModel.cells,
            dismissAction: viewModel.dismissAction
        )
    }
}

struct OperationDetailInfoInternalView: View {
    
    var title = "Детали операции"
    let logo: Image?
    let cells: [OperationDetailInfoViewModel.DefaultCellViewModel]
    let dismissAction: () -> Void
    
    var body: some View {
        
        VStack {
            
            HStack(alignment: .center, spacing: 0) {
                
                Button {
                    
                    dismissAction()
                    
                } label: {
                    
                    Image.ic24Close
                        .foregroundColor(.textSecondary)
                    
                }.padding(6)
                
                Spacer()
                
                Text(title)
                    .foregroundColor(.textSecondary)
                    .font(.textH4Sb16240())
                    .accessibilityIdentifier("OperationDetailInfoPageTitle")
                
                Spacer()
                
                if let logo {
                    
                    logo
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 32, height: 32)
                    
                } else {
                    
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                
            }
            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
            .frame(maxWidth: .infinity)
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    ForEach(cells) { item in
                        
                        switch item{
                            
                        case let propertyViewModel as OperationDetailInfoViewModel.PropertyCellViewModel:
                            PropertyCellView(viewModel: propertyViewModel)
                            
                        case let bankViewModel as OperationDetailInfoViewModel.BankCellViewModel:
                            BankCellView(viewModel: bankViewModel)

                        case let productViewModel as OperationDetailInfoViewModel.ProductCellViewModel:
                            ProductCellView(viewModel: productViewModel)
                            
                        case let iconCellViewModel as OperationDetailInfoViewModel.IconCellViewModel:
                            IconCellView(viewModel: iconCellViewModel)
                            
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
    }
    
}

extension OperationDetailInfoInternalView {
    
    struct PropertyCellView: View {
        
        var viewModel: OperationDetailInfoViewModel.PropertyCellViewModel
        
        var body: some View {
            
            HStack(alignment: .bottom, spacing: 15) {
                
                icon()
                    .frame(width: 32, height: 32, alignment: .bottom)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.textPlaceholder)
                        .font(.textBodySR12160())
                        .accessibilityIdentifier("OperationDetailInfoItemTitle")

                    Text(viewModel.value)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                        .accessibilityIdentifier("OperationDetailInfoItemData")

                    Color.bordersDivaiderDisabled
                        .frame(height: 1)
                }
            }.padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
        }

        @ViewBuilder
        private func icon() -> some View {
            
            if let image = viewModel.iconType {
                image
                    .resizable()
                    .renderingMode(.original)
                    .accessibilityIdentifier("OperationDetailInfoItemIcon")
            } else {
                Color.clear
                    .accessibilityIdentifier("OperationDetailInfoMissingIcon")
            }
        }
    }

    struct IconCellView: View {

        var viewModel: OperationDetailInfoViewModel.IconCellViewModel

        var body: some View {
            Group {
                viewModel.icon
                        .resizable()
                        .frame(width: 100, height: 50, alignment: .center)
            }.position(x: UIScreen.main.bounds.width/2)
                    .padding(.init(top: 30, leading: 0, bottom: 50, trailing: 50))
        }
    }

    struct BankCellView: View {
        
        var viewModel: OperationDetailInfoViewModel.BankCellViewModel
        
        var body: some View {
            
            HStack(alignment: .bottom, spacing: 15) {
                
                viewModel.icon
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .bottom)
                    .foregroundColor(.mainColorsGrayLightest)
                    .accessibilityIdentifier("OperationDetailInfoBankItemIcon")
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.textPlaceholder)
                        .font(.textBodySR12160())
                        .accessibilityIdentifier("OperationDetailInfoBankItemTitle")
                    
                    Text(viewModel.name)
                        .foregroundColor(.textSecondary)
                        .font(.textBodyMM14200())
                        .accessibilityIdentifier("OperationDetailInfoBankItemData")
                    
                    Color.bordersDivaiderDisabled
                        .frame(height: 1)
                }
            }.padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
            
        }
    }

    struct ProductCellView: View {
        
        var viewModel: OperationDetailInfoViewModel.ProductCellViewModel
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 15) {
                
                viewModel.icon
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 32, height: 32, alignment: .center)
                    .accessibilityIdentifier("OperationDetailInfoProductItemIcon")
                
                HStack{
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text(viewModel.title)
                            .foregroundColor(.textPlaceholder)
                            .font(.textBodySR12160())
                            .accessibilityIdentifier("OperationDetailInfoProductItemTitle")
                        
                        HStack{
                            
                            viewModel.iconPaymentService? 
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 24, height: 24, alignment: .center)
                                .accessibilityIdentifier("OperationDetailInfoProductItemPaymentSystemIcon")
                            
                            Text(viewModel.name)
                                .foregroundColor(.textSecondary)
                                .font(.textBodyMM14200())
                                .accessibilityIdentifier("OperationDetailInfoProductItemProductName")
                        }
                        Text(viewModel.description)
                            .foregroundColor(.textPlaceholder)
                            .font(.textBodySR12160())
                            .accessibilityIdentifier("OperationDetailInfoProductItemDescription")
                    }
                    
                    Spacer()
                    
                    Text(viewModel.balance)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                        .accessibilityIdentifier("OperationDetailInfoProductItemBalance")
                }
                
            }
            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        OperationDetailInfoView(viewModel: .detailMockData())
    }
}
