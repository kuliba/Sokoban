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
        
        VStack {
            
            // content
            VStack(spacing: 0) {
                
                HeaderView(viewModel: viewModel.header)
                OperationView(viewModel: viewModel.operation)
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
                        
                        FeatureButtonView(viewModel: buttonViewModel)
                    }
                }
                .padding(.top, 28)
            }
            
            if viewModel.isLoading {
                
                LoadingPlaceholder()
            }
        }
        .padding(.vertical, 40)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(item: $viewModel.sheet) { item in

            switch item.type {
            case .info(let operationDetailInfoViewModel):
                OperationDetailInfoView(viewModel: operationDetailInfoViewModel)
                
            case .printForm(let printFormViewModel):
                PrintFormView(viewModel: printFormViewModel)
                
            }
        }
        .fullScreenCoverLegacy(viewModel: $viewModel.fullScreenSheet) { item in
            
            switch item.type {
            case let .changeReturn(changeReturnViewModel):
                NavigationView {
                    ChangeReturnView(viewModel: changeReturnViewModel)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}

extension OperationDetailView {
    
    struct PayeeView: View {
        
        let viewModel: OperationDetailViewModel.PayeeViewModel
        
        var body: some View {
            
            switch viewModel {
            case .singleRow(let name):
                Text(name)
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                
                
            case .doubleRow(let name, let extra):
                VStack {
                    Text(name)
                        .font(.system(size: 16, weight: .regular))
                        .multilineTextAlignment(.center)
                    Text(extra)
                        .font(.system(size: 16, weight: .regular))
                        .multilineTextAlignment(.center)
                }
                
            case .number(let name, let title, let number, let action):
                VStack {
                    Text(name)
                        .font(.system(size: 16, weight: .regular))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0))
                        .multilineTextAlignment(.center)
                    Text(title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "999999"))
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
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
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
    
    struct FeatureButtonView: View {
        
        let viewModel: OperationDetailViewModel.FeatureButtonViewModel
        
        var body: some View {
            
            switch viewModel.kind {
            case .template(let selected):
                if selected == true {
                    
                    Button {
                        
                        viewModel.action()
                        
                    } label: {
                     
                        VStack(spacing: 12) {
                            
                            Image(viewModel.icon)
                                .resizable()
                                .frame(width: 56, height: 56)
                            
                            HStack(spacing: 3) {
                                
                                Image("Operation Details Template Check Icon")
                                Text(viewModel.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "#22C183"))
                            }
                        }
                    }
                    
                } else {
                    
                    VStack(spacing: 12) {
                        
                        Button {
                            
                            viewModel.action()
                            
                        } label: {
                            
                            Image(viewModel.icon)
                                .resizable()
                                .frame(width: 56, height: 56)
                        }
                        
                        Text(viewModel.name)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                
            default:
                VStack(spacing: 12) {
                    
                    Button {
                        
                        viewModel.action()
                        
                    } label: {
                        
                        Image(viewModel.icon)
                            .resizable()
                            .frame(width: 56, height: 56)
                    }
                    
                    Text(viewModel.name)
                        .font(.system(size: 12, weight: .medium))
                }
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
        
        Group {
            
            OperationDetailView(viewModel: .sampleComplete)
        }
    }
}

//MARK: - Sample Data

extension OperationDetailViewModel {
    
    static let sampleComplete: OperationDetailViewModel = {
        
        let header = HeaderViewModel(logo: Image(uiImage: UIImage(named: "Bank Logo Sample")!), status: .success, title: "Заголовок",  category: "Прочее")
        
        let operation = OperationViewModel(bankLogo: Image(uiImage: UIImage(named: "Bank Logo Sample")!), payee: .doubleRow("payeeFullName", "payeeAccountNumber"), amount: .init(amount: "30,5 $", payService: .applePay, colorHex: "1C1C1C"), fee: .init(title: "Комиссия:", amount: "50,00"), description: "Описание операции", date: "22.11.22")
        
        let actionButtons = [ActionButtonViewModel(name: "Изменить", action: {}), ActionButtonViewModel(name: "Вернуть", action: {})]
        
        let featureButtons = [FeatureButtonViewModel(kind: .template(false), icon: "Operation Details Template", name: "+ Шаблон", action: {}), FeatureButtonViewModel(kind: .document, icon: "Operation Details Document", name: "Документ", action: {}), FeatureButtonViewModel(kind: .info, icon: "Operation Details Info", name: "Детали", action: {})]
        
        return OperationDetailViewModel(id: "1", header: header, operation: operation, actionButtons: actionButtons, featureButtons: featureButtons, isLoading: false)
        
    }()
}
