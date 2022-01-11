//
//  OperationDetailView.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import SwiftUI
import Shimmer

struct OperationDetailView: View {
    
    @ObservedObject var viewModel: OperationDetailViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.clear
            
            VStack {
                
                Spacer()
                
                VStack {
                    // close button
                    HStack(alignment: .top) {
                        
                        Spacer()
                        
                        Button {
                            
                            viewModel.dismissAction()
                            
                        } label: {
                            
                            Image("Operation Details Close Button Icon")
                        }
                        .padding()
                    }
                    
                    // content
                    VStack(spacing: 0) {
                        
                        HeaderView(viewModel: $viewModel.header)
                        OperationView(viewModel: $viewModel.operation)
                            .padding(.top, 24)

                        // change, return buttons
                        if let actionButtons = viewModel.actionButtons {
                            
                            HStack(spacing: 15) {
                                
                                ForEach(actionButtons) { buttonViewModel in
                                    
                                    Button(buttonViewModel.name) {
                                        
                                        buttonViewModel.action()
                                    }
                                    .buttonStyle(OperationDetailsActionButton(width: 160))
                                    .frame(height: 40)
                                }
                                
                            }.padding(.top, 28)
                        }
                        
                        // template, document, details buttons
                        HStack(spacing: 52) {
                            
                            ForEach(viewModel.featureButtons) { buttonViewModel in
                                
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
                        }
                        .padding(.top, 28)
                        .animation(nil)
                    }
                    
                    if viewModel.isLoading {
                        
                        LoadingPlaceholder()
                    }
                    
                    // padding bottom
                    Color.white
                        .frame(height: 40)
                    
                }
                .background(Color.white)
                .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
                
            }
        }
        .transition(.scale)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(item: $viewModel.operationDetailInfoViewModel) {  operationDetailInfoViewModel in
            
            OperationDetailInfoView(viewModel: operationDetailInfoViewModel)
        }
    }
}

extension OperationDetailView {
    
    struct HeaderView: View {
        
        @Binding var viewModel: OperationDetailViewModel.HeaderViewModel
        
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
                
                Text(viewModel.title)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                
                if let category = viewModel.category {
                    
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
                
            case .number(let name, let number, let action):
                VStack {
                    Text(name)
                        .font(.system(size: 16, weight: .regular))
                    
                    HStack {
                        
                        Text(number)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.black)
                            .padding(.leading, 6)
                        
                        
                        Button {
                            
                            action()
                            
                        } label: {
                            
                            Image("Operation Details Copy Button Icon")
                        }.padding(6)
                    }
                    .padding(8)
                    .background(Color(hex: "F6F6F7"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
    
    struct LoadingPlaceholder: View {
        
        var body: some View {
            
            VStack {
                
                Color(hex: "F6F6F7")
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(height: 20)
                    .padding()
                    .padding(.horizontal, 10)
                    .shimmering(active: true, bounce: true)
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

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}


struct OperationDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OperationDetailView(viewModel: .sampleMin)
    }
}
