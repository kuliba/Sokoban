//
//  OperationDetailView.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import SwiftUI

struct OperationDetailView: View {
    
    @ObservedObject var viewModel: OperationDetailViewModel
    
    var body: some View {
        
        ZStack {
            
            // close button
            VStack {
                
                HStack(alignment: .top) {
                    
                    Spacer()
                    
                    Button {
                        viewModel.dismissAction()
                        
                    } label: {
                        Image("Operation Details Close Button Icon")
                    }
                    .padding()
                    
                    
                }
                Spacer()
            }
            
            // content
            VStack(spacing: 0) {
 
                GroupView(viewModel: $viewModel.group)
                OperationView(viewModel: $viewModel.operation)
                    .padding(.top, 24)
                
                if let actionButtons = viewModel.actionButtons {
                    
                    HStack(spacing: 15) {
                        
                        ForEach(actionButtons, id: \.self) { buttonViewModel in
                            
                            Button(buttonViewModel.name) {
                                
                                buttonViewModel.action()
                            }
                            .buttonStyle(OperationDetailsActionButton(width: 160))
                            .frame(height: 40)
                        }
                        
                    }.padding(.top, 28)
                }
                
                if let featureButtons = viewModel.featureButtons {
                    
                    HStack(spacing: 52) {
                        
                        ForEach(featureButtons, id: \.self) { buttonViewModel in
                            
                            VStack(spacing: 12) {
                                
                                Button {
                                    
                                    buttonViewModel.action()
                                    
                                } label: {
                                    
                                    Image(buttonViewModel.icon)
                                        .resizable()
                                        .frame(width: 56, height: 56)
                                }
                                
                                Text(buttonViewModel.name)
                                    .font(.system(size: 12, weight: .medium))
                            }
                        }
                    }.padding(.top, 28)
                }
            }
        }
    }
}

extension OperationDetailView {
    
    struct GroupView: View {
        
        @Binding var viewModel: OperationDetailViewModel.GroupViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                
                viewModel.logo
                    .resizable()
                    .frame(width: 64, height: 64)
                
                if let status = viewModel.status {
                    
                    Text(status.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: status.colorHex))
                        .padding(.top, 24)
                }
                
                Text(viewModel.merchant)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                
                if let category = viewModel.name {
                    
                    Text(category)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    struct OperationView: View {
        
        @Binding var viewModel: OperationDetailViewModel.OperationViewModel
        
        var body: some View {
            
            VStack(spacing: 0) {
                
                if let logo = viewModel.bankLogo {
                    
                    logo.resizable().frame(width: 32, height: 32)
                }
                
                if let payee = viewModel.payee {
                    
                    OperationDetailView.PayeeView(viewModel: payee)
                        .padding(.top, 8)
                }
                
                OperationDetailView.AmountView(viewModel: viewModel.amount)
                    .padding(.top, 32)
                
                if let fee = viewModel.fee {
                    
                    OperationDetailView.FeeView(viewModel: fee)
                        .padding(.top, 32)
                }
                
                if let description = viewModel.description {
                    
                    CapsuleText(text: description, color: .black, bgColor: Color(hex: "F6F6F7"), font: .system(size: 18, weight: .regular))
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                }
                
                Text(viewModel.date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "999999"))
                    .padding(.top, 16)
            }
        }
    }
    
    struct PayeeView: View {
        
        let viewModel: OperationDetailViewModel.PayeeViewModel
        
        var body: some View {
            
            switch viewModel {
            case .singleRow(let name):
                Text(name)
                    .font(.system(size: 16, weight: .regular))
                
            case .doubleRow(let name, let extra):
                VStack {
                    Text(name)
                        .font(.system(size: 16, weight: .regular))
                    Text(extra)
                        .font(.system(size: 16, weight: .regular))
                }
            }
        }
    }
    
    struct AmountView: View {
        
        let viewModel: OperationDetailViewModel.AmountViewModel
        
        var body: some View {
            
            if let payService = viewModel.payService {
                
                HStack {
                    
                    Text(viewModel.amount)
                        .font(.system(size: 24, weight: .semibold))
                    
                    Image(payService.iconName)
                }
                
            } else {
                
                Text(viewModel.amount)
                    .font(.system(size: 24, weight: .semibold))
            }
        }
    }
    
    struct FeeView: View {
        
        let viewModel: OperationDetailViewModel.FeeViewModel
        
        var body: some View {
            
            VStack {
                
                Text(viewModel.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "999999"))
                
                Text(viewModel.amount)
                    .font(.system(size: 16, weight: .regular))
                
            }
        }
    }
}

struct CapsuleText: View {
    
    let text: String
    let color: Color
    let bgColor: Color
    let font: Font
    
    var body: some View {
        
        Text(text)
            .font(font)
            .padding()
            .foregroundColor(color)
            .background(bgColor)
            .clipShape(Capsule())
    }
}


struct OperationDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperationDetailView(viewModel: .sample)
    }
}
