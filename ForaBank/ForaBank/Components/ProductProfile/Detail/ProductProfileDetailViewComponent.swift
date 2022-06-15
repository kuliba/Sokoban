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
        private var bindings = Set<AnyCancellable>()
        
        @Published var headerView: HeaderViewModel
        @Published var state: State
        @Published var amountViewModel: [AmountViewModel?]
        @Published var dateViewModel: DateProgressViewModel?
        @Published var footerViewModel: [FooterViewModel]?
        @Published var secondButtonsViewModel:[FooterViewModel]?
        @Published var circleViewModel: CircleViewModel?
        
        internal init(with loanBase: ProductCardData.LoanBaseParamInfoData?, status: StatusPC, availableExceedLimit: String, minimumPayment: String, gracePeriodPayment: String, overduePayment: String, ownFunds: String, debtAmount: String, totalAvailableAmount: String, totalDebtAmount: String, isCredit: Bool, productName: String?, longInt: Int?, sumAvailable: String?) {
            
            self.state = .init(collapsed: false)
            
            self.dateViewModel = nil
            self.footerViewModel = nil
            self.headerView = .init(subTitle: .paid, collapsed: false)
            self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .limit, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
            
            if let debtAmount = loanBase?.debtAmount, let ownFound = loanBase?.ownFunds, let availableExceedLimit = loanBase?.availableExceedLimit {
                
                self.circleViewModel = .init(debt: debtAmount, ownFound: ownFound, available: availableExceedLimit)
            }
            
            if status == .notActivated {
                
                self.headerView = .init(subTitle: .start, collapsed: false)
                self.dateViewModel = nil
                self.footerViewModel = nil
                self.amountViewModel = [.init(title: .ownfunds, foregraundColor: .gray, amount: availableExceedLimit, availebelAmount: nil), .init(title: .limit, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.secondButtonsViewModel = nil
            }
            
            if let overduePaymentData = loanBase?.overduePayment, overduePaymentData > 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: overduePayment, title: .delay, image: Image.ic24AlertCircle, foregraund: .buttonPrimary, background: .clear, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openBottomSheet"), object: nil, userInfo: nil)
                })]
                self.secondButtonsViewModel = [ .init(amount: totalDebtAmount, title: .totalDebt ,image: nil, foregraund: .white,  background: .clear, action: {}), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
            }
            
            if let availableExceedLimit = loanBase?.availableExceedLimit, availableExceedLimit == 0 {
                
                self.headerView = .init(subTitle: .paid, collapsed: false)
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
            }
            
            if let minimumPaymentData = loanBase?.minimumPayment, minimumPaymentData <= 0, let overduePaymenData = loanBase?.overduePayment, overduePaymenData <= 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
               
                self.footerViewModel = [.init(amount: "Внесен", title: .minimal, image: Image.ic24Check, foregraund: .white, background: .textPrimary, action: {
                    
                }), .init(amount: totalDebtAmount, title: .totalDebt, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
            }
            
            if let gracePeriodPaymentData = loanBase?.gracePeriodPayment, gracePeriodPaymentData > 0, let minimumPaymentData = loanBase?.minimumPayment, minimumPaymentData > 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = [.init(amount: totalDebtAmount, title: .totalDebt, image: nil, foregraund: .white, background: .clear, action: {})]
            }
 
            if let ownFundsData = loanBase?.ownFunds, ownFundsData > 0 {
                
                self.headerView = .init(subTitle: .paid, collapsed: false)
                self.dateViewModel = nil
                self.amountViewModel = [.init(title: .ownfunds, foregraundColor: .white, amount: ownFunds, availebelAmount: nil), .init(title: .limit, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                
                self.footerViewModel = []
                
                if let sumAvailable = sumAvailable {
                    footerViewModel?.append(.init(amount: sumAvailable, title: .available, image: nil, foregraund: .white, background: .clear, action: {}))
                }
                
                self.secondButtonsViewModel = nil
            }
            
            if let overduePayment = loanBase?.overduePayment, overduePayment == 0, loanBase?.gracePeriodPayment == 0, let ownFound = loanBase?.ownFunds, ownFound < 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: totalDebtAmount, title: .totalDebt, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
                
            }
            
            if loanBase?.overduePayment == 0, let gracePeriodPayment = loanBase?.gracePeriodPayment, gracePeriodPayment >= 0, let debtAmountData = loanBase?.debtAmount, debtAmountData > 0, let minimumPaymentData = loanBase?.minimumPayment, minimumPaymentData > 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: totalDebtAmount, title: .totalDebt, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
            }
            
            if let overduePaymentData = loanBase?.overduePayment, overduePaymentData > 0, let gracePeriodPaymentData = loanBase?.gracePeriodPayment, gracePeriodPaymentData >= 0, let debtAmountData = loanBase?.debtAmount, debtAmountData > 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: overduePayment, title: .delay, image: Image.ic24AlertCircle, foregraund: .buttonPrimary, background: .clear, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openBottomSheet"), object: nil, userInfo: nil)
                })]
                self.secondButtonsViewModel = [ .init(amount: totalDebtAmount, title: .totalDebt ,image: nil, foregraund: .white,  background: .clear, action: {}), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
            }
            
            if isCredit, let overduePayment = loanBase?.overduePayment, overduePayment > 0 {
                
                if let productName = productName, productName.contains(CreditType.consumer.rawValue) {
                    
                    self.headerView = .init(subTitle: .consumer, collapsed: false)
                } else {
                    
                    self.headerView = .init(subTitle: .mortgage, collapsed: false)
                }
                
                if let longInt = longInt {
                    
                    self.dateViewModel = .init(paymentDate: Date(timeIntervalSince1970: TimeInterval(longInt / 1000)), currentDate: Date())
                }
                
                self.amountViewModel = [.init(title: .creditAmount, foregraundColor: .mainColorsBlackMedium, amount: totalDebtAmount, availebelAmount: nil), .init(title: .repaid, foregraundColor: .buttonPrimary, amount: totalAvailableAmount, availebelAmount: nil)]
                
                if let totalDebtAmount = loanBase?.totalDebtAmount, let ownFunds = loanBase?.ownFunds, let totalAvailableAmount = loanBase?.totalAvailableAmount {
                    
                    self.circleViewModel = .init(debt: totalDebtAmount, ownFound: ownFunds, available: totalAvailableAmount)
                }
                self.footerViewModel = []
                
                self.footerViewModel?.append(.init(amount: minimumPayment, title: .minimalCredit, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }))
                
                self.footerViewModel?.append(.init(amount: " \(overduePayment)", title: .delay, image: Image.ic24AlertCircle, foregraund: .buttonPrimary, background: .clear, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openBottomSheet"), object: nil, userInfo: nil)

                }))
                
                self.secondButtonsViewModel = nil
            }
            
            if isCredit, let overduePayment = loanBase?.overduePayment, overduePayment <= 0 {
                
                if let productName = productName, productName.contains(CreditType.consumer.rawValue) {
                    
                    self.headerView = .init(subTitle: .consumer, collapsed: false)
                } else {
                    
                    self.headerView = .init(subTitle: .mortgage, collapsed: false)
                }
                
                if let longInt = longInt {
                    
                    self.dateViewModel = .init(paymentDate: Date(timeIntervalSince1970: TimeInterval(longInt / 1000)), currentDate: Date())
                }
                
                self.amountViewModel = [.init(title: .creditAmount, foregraundColor: .mainColorsBlackMedium, amount: totalDebtAmount, availebelAmount: nil), .init(title: .repaid, foregraundColor: .buttonPrimary, amount: totalAvailableAmount, availebelAmount: nil)]
                if let totalDebtAmount = loanBase?.totalDebtAmount, let ownFunds = loanBase?.ownFunds {
                    
                    self.circleViewModel = .init(debt: totalDebtAmount, ownFound: ownFunds, available: totalDebtAmount)
                }
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimalCredit, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                })]
                self.secondButtonsViewModel = nil
            }
            
            bind()
        }
        
        convenience init(with loanBase: ProductCardData.LoanBaseParamInfoData, status: StatusPC, isCredit: Bool, productName: String?, longInt: Int?) {
            
            self.init(with: loanBase, status: status, isCredit: isCredit, productName: productName, longInt: longInt)
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    switch action {
                    case _ as AntifraudViewModelAction.Cancel:
                        NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                    default:
                        break
                        
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Types

extension ProductProfileDetailView.ViewModel {
    
    struct HeaderViewModel {
        
        let title = "Детали счета"
        var subTitle: SubTitleViewModel
        var collapsed: Bool
        
        enum SubTitleViewModel {
            
            case paid
            case start
            case interval
            case delayCredit
            case mortgage
            case consumer
            
            var subTitle: String {
                
                switch self {
                    
                case .paid: return "Обязательный платеж погашен!\nУ вас нет задолженности"
                case .start: return "Поздравляем 🎉, Вы стали обладателем кредитной карты. Оплачивайте покупки и получайте Кешбэк и скидки от партнеров."
                case .interval: return "Отчетный период \(Date().startOfPreviusDate()) - \(Date().endOfMonth()) "
                case .delayCredit: return "Вносите платеж вовремя"
                case .consumer: return "Очередной платеж по кредиту"
                case .mortgage: return "Очередной платеж по ипотеке"
                }
            }
        }
    }
    
    struct CircleViewModel {
        
        var debt: Double
        
        var ownFound: Double
        
        var available: Double
        
        var colors: [Color] = [ .buttonPrimary, .white]
        
        var circleLimit: Double {
            
            let percent = (debt / (available + ownFound))
            return Double(percent)
            
        }
        
        var circleOwn: Double {
            
            let percent = 1 - circleLimit
            return Double(percent)
            
        }
        
        var total: Double {
            
            let total = ownFound + available
            return Double(total)
        }
        
    }
    
    struct AmountViewModel: Hashable {
        
        var title: Title
        var foregraundColor: Color
        var amount: String
        var availebelAmount: String?
        
        enum Title: Hashable {
            
            case debt
            case available
            case ownfunds
            case limit
            case repaid
            case creditAmount
            
            var title: String {
                
                switch self {
                    
                case .debt: return "Задолженность"
                case .available: return "Доступно"
                case .ownfunds: return "Собственные средства"
                case .limit: return "Кредитный лимит"
                case .repaid: return "Уже погашено"
                case .creditAmount: return "Сумма кредита"
                    
                }
            }
        }
        
    }
    
    struct FooterViewModel: Identifiable, Hashable {
        
        let id = UUID()
        var amount: String
        var title: Title
        var image: Image?
        var foregraund: Color
        var background: Color
        let action: () -> Void
        
        enum Title: Hashable {
            
            case minimal
            case preferential
            case totalDebt
            case available
            case delay
            case minimalCredit
            
            var title: String {
                
                switch self {
                    
                case .minimal: return "Минимальный платеж"
                case .preferential: return "Льготный платеж"
                case .totalDebt: return "Общая задолженность"
                case .available: return "Доступно"
                case .delay: return "Включая просрочку"
                case .minimalCredit: return "Внести платеж"
                }
            }
        }
        
        static func == (lhs: ProductProfileDetailView.ViewModel.FooterViewModel, rhs: ProductProfileDetailView.ViewModel.FooterViewModel) -> Bool {
            return lhs.amount == rhs.amount
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(amount)
        }
    }
    
    struct State {
        
        var collapsed: Bool
    }
}

//MARK: - View

struct ProductProfileDetailView: View {
    
    @ObservedObject var viewModel: ProductProfileDetailView.ViewModel
    
    var body: some View {
        
        VStack {
            
            if viewModel.headerView.collapsed {
                
                HeaderView(viewModel: $viewModel.headerView)
                    .padding(.horizontal, 20)
                
                if let dateProgress = viewModel.dateViewModel {
                    
//                    DateProgressView(viewModel: dateProgress)
//                        .padding(.horizontal, 20)
                } else {
                    
                    Divider()
                        .foregroundColor(.white.opacity(0.05))
                        .padding(.horizontal, 20)
                }
                
                MainBlock(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                
                if let footerViewModel = viewModel.footerViewModel {
                    
                    VStack(alignment: .leading) {
                        
                        FooterView(viewModel: footerViewModel)
                            .frame(alignment: .leading)
                        
                    }
                    .padding(.horizontal, 12)
                    
                }
                
                if let secondButtonViewModel = viewModel.secondButtonsViewModel {
                    
                    VStack(alignment: .leading) {
                        
                        FooterView(viewModel: secondButtonViewModel)
                            .frame(alignment: .leading)
                        
                    }
                    .padding(.horizontal, 12)
                }
                
            } else {
                
                HeaderView(viewModel: $viewModel.headerView)
                    .padding(.horizontal, 20)
                
                if let dateProgress = viewModel.dateViewModel {
                    
//                    DateProgressView(viewModel: dateProgress)
//                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 18)
        .background(Color.mainColorsBlack)
        .cornerRadius(12)
    }
    
    struct HeaderView: View {
        
        @Binding var viewModel: ProductProfileDetailView.ViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    
                    Text(viewModel.title)
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                    
                    Spacer()
                    
                    Button {
                        
                        viewModel.collapsed.toggle()
                        
                    } label: {
                        
                        if viewModel.collapsed {
                            
                            Image.ic24ChevronDown
                                .foregroundColor(.mainColorsGray)
                        } else {
                            
                            Image.ic24ChevronUp
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
                
                Text(viewModel.subTitle.subTitle)
                    .font(.system(size: 14))
                    .foregroundColor(.mainColorsGray)
                    .lineLimit(4)
                
            }
            .foregroundColor(.white)
        }
    }
    
    struct MainBlock: View {
        
        let viewModel: ProductProfileDetailView.ViewModel
        
        var body: some View {
            
            HStack(alignment: .center) {
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    ForEach(viewModel.amountViewModel, id: \.self) { amount in
                        
                        if let amount = amount {
                            
                            AmountView(viewModel: amount)
                                .frame(alignment: .center)
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    
                    ZStack {
                        
                        if let ownFound = viewModel.circleViewModel?.ownFound, let available = viewModel.circleViewModel?.available, ownFound > 0.1 {
                            
                            CircleSegmentedBarView(values: [ownFound, available], totalDebt: available + ownFound, colors: [.white, .buttonPrimary])
                            
                        } else if let debt = viewModel.circleViewModel?.debt, let available = viewModel.circleViewModel?.available {
                            
                            CircleSegmentedBarView(values: [available, debt], totalDebt: debt, colors: [.buttonPrimary, .cardInfinite])
                        }
                        
                        Image.ic24AlertCircle
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .background(Color.textPrimary)
                            .cornerRadius(90)
                    }
                    .frame(width: 96, height: 96)
                }
            }
            .frame(alignment: .center)
        }
    }
    
    struct AmountView: View {
        
        var viewModel: ProductProfileDetailView.ViewModel.AmountViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(viewModel.title.title)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                HStack {
                    
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(viewModel.foregraundColor)
                    
                    Text(viewModel.amount)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    if let availebleAmount = viewModel.availebelAmount {
                        
                        Text("/ \(availebleAmount)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                }
            }
        }
    }
    
    struct FooterView: View {
        
        var viewModel: [ProductProfileDetailView.ViewModel.FooterViewModel?]
        @State var showInfoModalView: Bool = false
        
        var body: some View {
            
            HStack {
                
                ForEach(viewModel, id: \.self) { button in
                    
                    Button {
                        
                        if let action = button?.action {
                            
                            action()
                            showInfoModalView = true
                            
                        } else {
                            
                        }
                        
                    } label: {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            
                            Text(button?.title.title ?? "")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                            
                            HStack {
                                
                                if let amount = button?.amount {
                                    
                                    Text(amount)
                                        .foregroundColor(.white)
                                }
                                
                                if let image = button?.image {
                                    image
                                        .foregroundColor(button?.foregraund)
                                }
                            }
                        }
                        .padding(.leading, 6)
                        .frame(width: 148, height: 54, alignment: .leading)
                        .background(button!.background)
                        
                    }
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {
            
            ProductProfileDetailView(viewModel: .start)
                .previewLayout(.fixed(width: 375, height: 300))

            ProductProfileDetailView(viewModel: .collapsed)
                .previewLayout(.fixed(width: 375, height: 300))

            ProductProfileDetailView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 300))

            ProductProfileDetailView(viewModel: .full)
                .previewLayout(.fixed(width: 375, height: 300))

            ProductProfileDetailView(viewModel: .fullwithButton)
                .previewLayout(.fixed(width: 375, height: 400))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel {

    static let start = ProductProfileDetailView.ViewModel(with: .sample, status: .notActivated, isCredit: false, productName: nil, longInt: nil)

    static let sample = ProductProfileDetailView.ViewModel(with: .sample, status: .notActivated, isCredit: false, productName: nil, longInt: nil)

    static let collapsed = ProductProfileDetailView.ViewModel(with: .sample, status: .notActivated, isCredit: false, productName: nil, longInt: nil)

    static let full = ProductProfileDetailView.ViewModel(with: .sample, status: .notActivated, isCredit: false, productName: nil, longInt: nil)

    static let fullwithButton = ProductProfileDetailView.ViewModel(with: .sample, status: .notActivated, isCredit: false, productName: nil, longInt: nil)
    
}

extension ProductCardData.LoanBaseParamInfoData {
    static let sample = ProductCardData.LoanBaseParamInfoData.init(loanId: 2, clientId: 2, number: "", currencyId: 2, currencyNumber: 2, currencyCode: "", minimumPayment: 2, gracePeriodPayment: 2, overduePayment: 2, availableExceedLimit: 2, ownFunds: 2, debtAmount: 2, totalAvailableAmount: 2, totalDebtAmount: 2)
}
