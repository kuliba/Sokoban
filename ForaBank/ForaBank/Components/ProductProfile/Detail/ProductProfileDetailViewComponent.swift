//
//  ProductProfileAccountDetailViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 11.03.2022.
//

import SwiftUI
import Combine
import UIPrimitives

//MARK: - ViewModel

extension ProductProfileDetailView {
    
    final class ViewModel: ObservableObject {

        let action: PassthroughSubject<Action, Never> = .init()
        
        lazy var header: HeaderViewModel = .init(action: { [weak self] in self?.action.send(ProductProfileDetailViewModelAction.ToggleCollapsed())})
        @Published var info: InfoViewModel
        @Published var mainBlock: MainBlockViewModel
        @Published var footer: FooterViewModel?
        @Published var isCollapsed: Bool
        @Published var isUpdating: Bool
        
        private let productId: ProductData.ID
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(info: InfoViewModel, mainBlock: MainBlockViewModel, footer: FooterViewModel?, isCollapsed: Bool, isUpdating: Bool = false, productId: ProductData.ID, model: Model = .emptyMock) {
            
            self.info = info
            self.mainBlock = mainBlock
            self.footer = footer
            self.isCollapsed = isCollapsed
            self.isUpdating = isUpdating
            self.productId = productId
            self.model = model
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductProfileDetailView.ViewModel initialized")
        }
        
        deinit {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductProfileDetailView.ViewModel deinitialized")
        }
        
        convenience init?(productCard: ProductCardData, model: Model) {
            
            guard let loanData = productCard.loanBaseParam,
                  let configuration = Configuration(productCard: productCard, loanData: loanData) else {
                return nil
            }
            
            let info = InfoViewModel(configuration: configuration)
            let mainBlock = MainBlockViewModel(configuration: configuration, productCard: productCard, loanData: loanData, amountFormatted: model.amountFormatted(amount:currencyCode:style:), action: {})
            let footer = FooterViewModel(configuration: configuration, loanData: loanData, model: model)
            let isCollapsed = configuration == .notActivated ? false : true
            
            self.init(info: info, mainBlock: mainBlock, footer: footer, isCollapsed: isCollapsed, isUpdating: false, productId: productCard.id, model: model)
            
            bind()
            bind(footer)
        }
        
        convenience init(productLoan: ProductLoanData, loanData: PersonsCreditData, model: Model) {
            
            let info = InfoViewModel(loanData: loanData, loanType: productLoan.loanType)
            let mainBlock = MainBlockViewModel(productLoan: productLoan, loanData: loanData, model: model, action: {})
            let footer = FooterViewModel(productLoan: productLoan, loanData: loanData, model: model)
            
            self.init(info: info, mainBlock: mainBlock, footer: footer, isCollapsed: false, isUpdating: false, productId: productLoan.id, model: model)
            
            bind()
            bind(footer)
        }
        
        func update(productCard: ProductCardData, model: Model) {
            
            guard let loanData = productCard.loanBaseParam,
                  let configuration = Configuration(productCard: productCard, loanData: loanData) else {
                return
            }
            
            info = .init(configuration: configuration)
            mainBlock = .init(configuration: configuration, productCard: productCard, loanData: loanData, amountFormatted: model.amountFormatted(amount:currencyCode:style:), action: {})
            footer = .init(configuration: configuration, loanData: loanData, model: model)
        }
        
        func update(productLoan: ProductLoanData, loanData: PersonsCreditData, model: Model) {
            
            info = .init(loanData: loanData, loanType: productLoan.loanType)
            mainBlock = .init(productLoan: productLoan, loanData: loanData, model: model, action: {})
            footer = .init(productLoan: productLoan, loanData: loanData, model: model)
            bind(footer)
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
            
            model.loansUpdating
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] loansUpdating in
                    
                    withAnimation {
                      
                        isUpdating = loansUpdating.contains(productId)
                    }
                    
                }.store(in: &bindings)
            
            model.productsUpdating
                .combineLatest(model.productsFastUpdating)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
    
                    let totalUpdating = data.0
                    let fastUpdating = data.1
                    
                    withAnimation {
                        
                        if totalUpdating.contains(.card) {
                            
                            isUpdating = true
                            
                        } else {
                            
                            isUpdating = fastUpdating.contains(productId)
                        }
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
        
        private func bind(_ footerViewModel: FooterViewModel?) {
            
            guard let footerViewModel = footerViewModel else {
                return
            }
            
            footerViewModel.action
                .receive(on: DispatchQueue.main)
                .sink{ [unowned self] action in
                    
                    switch action {
                    case let payload as ProductProfileDetailFooterAction.MakePayment:
                        self.action.send(ProductProfileDetailViewModelAction.MakePayment(settlementAccountId: payload.settlementAccountId, amount: payload.amount))
                        
                    default:
                        break
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
    
    struct MakePayment: Action {
        
        let settlementAccountId: Int
        let amount: Double
    }
}

//MARK: - View

struct ProductProfileDetailView: View {
    
    @ObservedObject var viewModel: ProductProfileDetailView.ViewModel
    @Namespace var namespace
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsBlack)
                .zIndex(0)
            
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
            .zIndex(1)
            
            if viewModel.isUpdating == true {
                
                Color.mainColorsBlackMedium
                    .shimmering()
                    .blendMode(.colorDodge)
                    .zIndex(2)
            }
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
    
    static let sampleCollapsed = ProductProfileDetailView.ViewModel(info: .sampleProgress, mainBlock: .sampleCreditCard, footer: .sample, isCollapsed: true, productId: 0)
    
    static let sample = ProductProfileDetailView.ViewModel(info: .sampleProgress, mainBlock: .sampleCreditCard, footer: .sample, isCollapsed: false, productId: 0)
    
    static let sampleMessage = ProductProfileDetailView.ViewModel(info: .sampleMessage, mainBlock: .sampleCredit, footer: nil, isCollapsed: false, productId: 0)
}
