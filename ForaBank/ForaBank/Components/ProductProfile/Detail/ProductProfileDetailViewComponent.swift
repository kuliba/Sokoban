//
//  ProductProfileAccountDetailViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 11.03.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileDetailView {
    
    class ViewModel: ObservableObject {

        let action: PassthroughSubject<Action, Never> = .init()
        
        lazy var header: HeaderViewModel = .init(action: { [weak self] in self?.action.send(ProductProfileDetailViewModelAction.ToggleCollapsed())})
        @Published var info: InfoViewModel
        @Published var mainBlock: MainBlockViewModel
        @Published var footer: FooterViewModel?
        @Published var isCollapsed: Bool
        
        private var bindings = Set<AnyCancellable>()
        
        internal init(info: InfoViewModel, mainBlock: MainBlockViewModel, footer: FooterViewModel?, isCollapsed: Bool) {
            
            self.info = info
            self.mainBlock = mainBlock
            self.footer = footer
            self.isCollapsed = isCollapsed
            
            bind()
        }
        
        init?(productCard: ProductCardData, model: Model) {
            
            guard let loanData = productCard.loanBaseParam,
                  let configuration = Configuration(productCard: productCard, loanData: loanData) else {
                return nil
            }
            
            self.info = .init(configuration: configuration)
            self.mainBlock = .init(configuration: configuration, loanData: loanData, model: model, action: {})
            self.footer = .init(configuration: configuration, loanData: loanData, model: model)
            self.isCollapsed = configuration == .notActivated ? true : false
            
            bind()
        }
        
        init(productLoan: ProductLoanData, loanData: PersonsCreditData, model: Model) {
            
            self.info = .init(loanData: loanData, loanType: productLoan.loanType)
            self.mainBlock = .init(productLoan: productLoan, loanData: loanData, model: model, action: {})
            self.footer = .init(productLoan: productLoan, loanData: loanData, model: model)
            self.isCollapsed = false
            
            bind()
        }

        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductProfileDetailViewModelAction.ToggleCollapsed:
                        withAnimation {
                            
                            isCollapsed.toggle()
                        }
  
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    withAnimation {
                        
                        header.isCollapsed = isCollapsed
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Configuration

extension ProductProfileDetailView.ViewModel {
    
    enum Configuration {
        
        case notActivated
        case minimumPaymentAndGrasePeriod
        case overdue
        case loanRepaidAndOwnFunds
        case entireLoanUsed
        case minimumPaymentMade
        case overdraft
        case withoutGrasePeriod
        case withoutGrasePeriodWithOverdue
        case minimumPaymentMadeGrasePeriodRemain
        
        init?(productCard: ProductCardData, loanData: ProductCardData.LoanBaseParamInfoData) {
            
            if productCard.isActivated == true {
                
                if let minimumPayment = loanData.minimumPayment,
                   let gracePeriodPayment = loanData.gracePeriodPayment,
                   minimumPayment > 0 && gracePeriodPayment > 0 {
                    
                    self = .minimumPaymentAndGrasePeriod
                    
                } else if let overduePayment = loanData.overduePayment,
                          overduePayment > 0 {
                    
                    self = .overdue
                    
                } else if let ownFunds = loanData.ownFunds,
                          ownFunds > 0 {
                    
                    self = .loanRepaidAndOwnFunds
                    
                } else if let availableExceedLimit = loanData.availableExceedLimit,
                          availableExceedLimit == 0 {
                    
                    self = .entireLoanUsed
                    
                } else if let minimumPayment = loanData.minimumPayment,
                          let overduePayment = loanData.overduePayment,
                          minimumPayment <= 0,
                          overduePayment <= 0 {
                    
                    self = .minimumPaymentMade
                    
                } else if let overduePayment = loanData.overduePayment,
                          let gracePeriodPayment = loanData.gracePeriodPayment,
                          let ownFunds = loanData.ownFunds,
                          overduePayment == 0,
                          gracePeriodPayment == 0,
                          ownFunds < 0 {
                    
                    self = .overdraft
                    
                } else if let gracePeriodPayment = loanData.gracePeriodPayment,
                          let overduePayment = loanData.overduePayment,
                          let debtAmount = loanData.debtAmount,
                          let minimumPayment = loanData.minimumPayment,
                          gracePeriodPayment >= 0,
                          overduePayment == 0,
                          debtAmount > 0,
                          minimumPayment > 0 {
                    
                    self = .withoutGrasePeriod
                    
                } else if let gracePeriodPayment = loanData.gracePeriodPayment,
                          let overduePayment = loanData.overduePayment,
                          let debtAmount = loanData.debtAmount,
                          gracePeriodPayment >= 0,
                          overduePayment > 0,
                          debtAmount > 0 {
                    
                    self = .withoutGrasePeriodWithOverdue
                    
                } else if let gracePeriodPayment = loanData.gracePeriodPayment,
                          let minimumPayment = loanData.minimumPayment,
                          let overduePayment = loanData.overduePayment,
                          gracePeriodPayment >= 0,
                          minimumPayment <= 0,
                          overduePayment <= 0 {
                    
                    self = .minimumPaymentMadeGrasePeriodRemain
                    
                } else {
                    
                    return nil
                }
                
            } else {
                
                self = .notActivated
            }
        }
    }
}

//MARK: - Actions

enum ProductProfileDetailViewModelAction {

    struct ToggleCollapsed: Action {}
}

//MARK: - View

struct ProductProfileDetailView: View {
    
    @ObservedObject var viewModel: ProductProfileDetailView.ViewModel

    @available(iOS 14.0, *)
    @Namespace var namespace
    
    var body: some View {
        
        if #available(iOS 14, *) {
            
            VStack(spacing: 0) {
                
                ProductProfileDetailView.HeaderView(viewModel: viewModel.header)
                
                ProductProfileDetailView.InfoView(viewModel: viewModel.info, isCollapsed: $viewModel.isCollapsed)
                    .padding(.top, 16)
                
                if viewModel.isCollapsed == false {
                    
                    ProductProfileDetailView.MainBlockView(viewModel: viewModel.mainBlock)
                        .matchedGeometryEffect(id: "main", in: namespace)
                        .frame(height: 112)
                        .padding(.top, 22)
                    
                } else {
                    
                    Color.clear
                        .matchedGeometryEffect(id: "main", in: namespace)
                        .frame(height: 0.05)
                }
                
                if viewModel.isCollapsed == false {
                    
                    if let footerViewModel = viewModel.footer {
                        
                        ProductProfileDetailView.FooterView(viewModel: footerViewModel)
                            .matchedGeometryEffect(id: "footer", in: namespace)
                            .padding(.top, 26)
                    }
                    
                } else {
                    
                    Color.clear
                        .matchedGeometryEffect(id: "footer", in: namespace)
                        .frame(height: 0.05)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 18)
            .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsBlack))
            
        } else {
            
            VStack {
                
                if viewModel.isCollapsed == true {
                    
                    ProductProfileDetailView.HeaderView(viewModel: viewModel.header)
                    ProductProfileDetailView.InfoView(viewModel: viewModel.info, isCollapsed: $viewModel.isCollapsed)
                    
                } else {
                    
                    ProductProfileDetailView.HeaderView(viewModel: viewModel.header)
                    ProductProfileDetailView.InfoView(viewModel: viewModel.info, isCollapsed: $viewModel.isCollapsed)
                    
                    ProductProfileDetailView.MainBlockView(viewModel: viewModel.mainBlock)
                        .frame(height: 112)
                    
                    if let footerViewModel = viewModel.footer {
                        
                        ProductProfileDetailView.FooterView(viewModel: footerViewModel)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 18)
            .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsBlack))
        }
    }
}



//MARK: - Preview

struct ProductProfileDetailView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {
            
            ProductProfileDetailView(viewModel: .sampleCollapsed)
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 180))
            
            ProductProfileDetailView(viewModel: .sampleMessage)
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 300))
            
            ProductProfileDetailView(viewModel: .sample)
                .padding(.horizontal, 20)
                .previewLayout(.fixed(width: 375, height: 420))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel {
    
    static let sampleCollapsed = ProductProfileDetailView.ViewModel(info: .sampleProgress, mainBlock: .sampleCreditCard, footer: .sample, isCollapsed: true)
    
    static let sample = ProductProfileDetailView.ViewModel(info: .sampleProgress, mainBlock: .sampleCreditCard, footer: .sample, isCollapsed: false)
    
    static let sampleMessage = ProductProfileDetailView.ViewModel(info: .sampleMessage, mainBlock: .sampleCredit, footer: nil, isCollapsed: false)
}
