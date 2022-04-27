//
//  OperationDetailInfoView.swift
//  ForaBank
//
//  Created by Дмитрий on 27.12.2021.
//

import SwiftUI
import Combine


struct OperationDetailInfoView: View {
    
    var viewModel: OperationDetailInfoViewModel
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center, spacing: 0){
                Button {
                    
                    viewModel.dismissAction()
                    
                } label: {
                    
                    Image("xmarknew")
                }.padding(6)
                Spacer()
                Text(viewModel.title)
                    .foregroundColor(Color(hex: "1C1C1C"))
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                Spacer()
                if let logo = viewModel.logo {
                    
                    logo
                        .resizable()
                        .frame(width: 32, height: 32)
                } else {
                    
                    Color.clear
                        .frame(width: 32, height: 32)
                }
                
            }
            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
            .frame(maxWidth: .infinity)
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 20){
                    ForEach(viewModel.cells) { item in
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

extension OperationDetailInfoView {
    
    struct PropertyCellView: View {
        
        var viewModel: OperationDetailInfoViewModel.PropertyCellViewModel
        
        var body: some View {
            HStack(alignment: .bottom, spacing: 15){
                viewModel.iconType?.icon
                    .frame(width: 32, height: 24, alignment: .bottom)
                VStack(alignment: .leading, spacing: 4){
                    Text(viewModel.title)
                        .foregroundColor(Color(hex: "999999"))
                        .font(.system(size: 12))
                    Text(viewModel.value)
                        .font(.system(size: 14))
                    Color(hex: "FBFBFB")
                        .frame(height: 1)
                }
            }.padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
            
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
            HStack(alignment: .bottom, spacing: 15){
                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .bottom)
                
                VStack(alignment: .leading, spacing: 4){
                    Text(viewModel.title)
                        .foregroundColor(Color(hex: "999999"))
                        .font(.system(size: 12))
                    Text(viewModel.name)
                        .font(.system(size: 14))
                    Color(hex: "FBFBFB")
                        .frame(height: 1)
                }
            }.padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
            
        }
    }

    struct ProductCellView: View {
        
        var viewModel: OperationDetailInfoViewModel.ProductCellViewModel
        
        var body: some View {
            HStack(alignment: .center, spacing: 15){
                viewModel.icon
                    .frame(width: 32, height: 22, alignment: .center)
                HStack{
                    VStack(alignment: .leading, spacing: 4){
                        Text(viewModel.title)
                            .foregroundColor(Color(hex: "999999"))
                            .font(.system(size: 12))
                        HStack{
                            viewModel.iconPaymentService?
                                .frame(width: 24, height: 24, alignment: .center)
                            Text(viewModel.name)
                                .font(.system(size: 14))
                        }
                        Text(viewModel.description)
                            .foregroundColor(Color(hex: "999999"))
                            .font(.system(size: 12))
                    }
                    Spacer()
                    Text(viewModel.balance)
                        .font(.system(size: 14))
                }
                
            }
            .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
        }
    }
}




struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        OperationDetailInfoView(viewModel: .detailMockData)
    }
}
