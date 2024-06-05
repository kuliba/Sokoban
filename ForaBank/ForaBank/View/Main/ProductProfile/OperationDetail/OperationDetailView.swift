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
                
                // template, document, details buttons
                HStack(spacing: 52) {
                    
                    if let template = viewModel.templateButton {
                        
                        TemplateButtonView(viewModel: template)
                    }
                    
                    ForEach(viewModel.featureButtons) { buttonViewModel in
                        
                        FeatureButtonView(viewModel: buttonViewModel)
                    }
                }
                .padding(.top, 28)
                
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
            }
            
            if viewModel.isLoading {
                
                LoadingPlaceholder()
            }
        }
        .padding(.vertical, 40)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(item: $viewModel.sheet) { item in
            
            switch item.kind {
            case .info(let operationDetailInfoViewModel):
                OperationDetailInfoView(viewModel: operationDetailInfoViewModel)
                
            case .printForm(let printFormViewModel):
                PrintFormView(viewModel: printFormViewModel)
                
            }
        }
        .fullScreenCoverLegacy(viewModel: $viewModel.fullScreenSheet) { item in
            
            switch item.type {
            case let .payments(viewModel):
                NavigationView {
                    
                    PaymentsView(viewModel: viewModel)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
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
            
            VStack(spacing: 1) {
                
                Text(viewModel.title)
                    .foregroundColor(.textPlaceholder)
                
                Text(viewModel.amount)
                    .foregroundColor(.textSecondary)
            }
            .font(.system(size: 16, weight: .regular))
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
                    .shimmering()
            }
        }
    }
    
    struct FeatureButtonView: View {
        
        let viewModel: OperationDetailViewModel.FeatureButtonViewModel
        
        var body: some View {
            
            switch viewModel.kind {
            case .template:
                EmptyView()
                    .frame(width: 10, height: 10, alignment: .center)
                
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
            .foregroundColor(color)
            .padding(8)
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
        
        let productStatementData = ProductStatementData(mcc: 3245, accountId: 10004111477, accountNumber: "70601810711002740401", amount: 144.21, cardTranNumber: "4256901080508437", city: "string", comment: "Перевод денежных средств. НДС не облагается.", country: "string", currencyCodeNumeric: 810, date: Date(), deviceCode: "string", documentAmount: 144.21, documentId: 10230444722, fastPayment: .init(documentComment: "string", foreignBankBIC: "044525491", foreignBankID: "10000001153", foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"", foreignName: "Петров Петр Петрович", foreignPhoneNumber: "70115110217", opkcid: "A1355084612564010000057CAFC75755", operTypeFP: "string", tradeName: "string", guid: "string"), groupName: "Прочие операции", isCancellation: false, md5hash: "75f3ee3b2d44e5808f41777c613f23c9", merchantName: "DBO MERCHANT FORA, Zubovskiy 2", merchantNameRus: "DBO MERCHANT FORA, Zubovskiy 2", opCode: 1, operationId: "909743", operationType: .debit, paymentDetailType: .betweenTheir, svgImage: .init(description: "string"), terminalCode: "41010601", tranDate: nil, type: OperationEnvironment.inside)
        
        let product = ProductData(id: 0, productType: .card, number: nil, numberMasked: nil, accountNumber: nil, balance: nil, balanceRub: nil, currency: "RUB", mainField: "CARD", additionalField: nil, customName: nil, productName: "CARD", openDate: nil, ownerId: 1, branchId: nil, allowCredit: true, allowDebit: true, extraLargeDesign: .init(description: ""), largeDesign: .init(description: ""), mediumDesign: .init(description: ""), smallDesign: .init(description: ""), fontDesignColor: .init(description: ""), background: [], order: 1, isVisible: true, smallDesignMd5hash: "", smallBackgroundDesignHash: "")
        
        return .init(productStatement: productStatementData, product: product, updateFastAll: {}, model: .emptyMock)
    }()
}
