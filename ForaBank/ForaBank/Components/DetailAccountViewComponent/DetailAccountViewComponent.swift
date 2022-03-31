//
//  DetailAccountComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 11.03.2022.
//

import SwiftUI
import Combine

extension DetailAccountViewComponent {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        private var bindings = Set<AnyCancellable>()
        
        @Published var headerView: HeaderViewModel
        @Published var state: State
        @Published var amountViewModel: [AmountViewModel?]
        @Published var dateViewModel: DateViewModel?
        @Published var footerViewModel: [FooterViewModel]?
        @Published var secondButtonsViewModel:[FooterViewModel]?
        
        @Published var circleViewModel: CircleViewModel?
        
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
        
        struct DateViewModel {
            
            var longInt: Int?
            
            var creditDate: String? {
                
                if let longInt = longInt {
                    let date = Date(timeIntervalSince1970: TimeInterval(longInt/1000))
                    let dateFormatter = DateFormatter.dateAndMonth
                    
                    dateFormatter.timeZone = .current
                    dateFormatter.locale = Locale(identifier: "ru_RU")
                    let localDate = dateFormatter.string(from: date)
                    
                    return "Дата платежа - \(localDate)"
                } else {
                    return nil
                }
            }
            
            var date: String {
                
                let currentDate = Date()
                var components = Calendar.current.dateComponents([.year, .month], from: currentDate)
                components.month = (components.month ?? 0) + 1
                components.hour = (components.hour ?? 0) - 1
                let endOfMonth = Calendar.current.date(from: components)!
                let formatter = DateFormatter.dateAndMonth
                let date = formatter.string(from: endOfMonth)
                
                return "Дата платежа - \(date)"
            }
            
            var lostDays: String {
                
                if let longInt = longInt {
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(longInt/1000))
                    let currentDate = Date()
                    var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    components.day = (components.day ?? 0) + 1
                    let endOfMonth = Calendar.current.date(from: components)!
                    let distance = currentDate.distance(to: endOfMonth)
                    return "\(distance.stringFormatted()) Дней"
                    
                } else {
                    
                    let currentDate = Date()
                    var components = Calendar.current.dateComponents([.year, .month], from: currentDate)
                    components.month = (components.month ?? 0) + 1
                    components.hour = (components.hour ?? 0) + 1
                    let endOfMonth = Calendar.current.date(from: components)!
                    let distance = currentDate.distance(to: endOfMonth)
                    return "\(distance.stringFormatted()) Дней"
                }
            }
            
            var value: Double {
                
                var now: Double {
                    
                    let now = Calendar.current.component(.day, from: Date())
                    
                    return Double(now)
                }
                
                var maxValue: Int {
                    
                    if let longInt = longInt {
                        
                        let date = Date(timeIntervalSince1970: TimeInterval(longInt/1000))
                        let currentDate = Date()
                        
                        let interval = date - currentDate
                        
                        guard let interval = interval.day else {
                            return 0
                        }
                        return interval
                        
                    } else {
                        let nowDate = Date()
                        let calendar = Calendar.current
                        
                        let dateComponents = DateComponents(year: calendar.component(.year, from: nowDate), month: calendar.component(.month, from: nowDate))
                        let date = calendar.date(from: dateComponents)!
                        
                        let range = calendar.range(of: .day, in: .month, for: date)!
                        let numDays = range.count
                        
                        return numDays
                    }
                }
                
                var percentage = now / Double(maxValue)
                
                if longInt != nil {
                    percentage = 1.0 - (Double(maxValue) / 31.0)
                }
                
                return Double(percentage)
            }
            
            init(longInt: Int?) {
                
                self.longInt = longInt
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
            
            static func == (lhs: DetailAccountViewComponent.ViewModel.FooterViewModel, rhs: DetailAccountViewComponent.ViewModel.FooterViewModel) -> Bool {
                return lhs.amount == rhs.amount
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(amount)
            }
        }
        
        struct State {
            
            var collapsed: Bool
        }
        
        internal init(with loanBase: LoanBaseParamModel, status: StatusPC, availableExceedLimit: String, minimumPayment: String, gracePeriodPayment: String, overduePayment: String, ownFunds: String, debtAmount: String, totalAvailableAmount: String, totalDebtAmount: String, isCredit: Bool, productName: String?, longInt: Int?) {
            
            self.state = .init(collapsed: false)
            
            self.dateViewModel = .init(.init(longInt: nil))
            self.footerViewModel = nil
            self.headerView = .init(subTitle: .paid, collapsed: false)
            self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .limit, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
            self.circleViewModel = .init(debt: loanBase.debtAmount, ownFound: loanBase.ownFunds, available: loanBase.availableExceedLimit)
            
            if status == .notActivated {
                
                self.headerView = .init(subTitle: .start, collapsed: false)
                self.dateViewModel = nil
                self.footerViewModel = nil
                self.amountViewModel = [.init(title: .ownfunds, foregraundColor: .gray, amount: availableExceedLimit, availebelAmount: nil), .init(title: .limit, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.secondButtonsViewModel = nil
            }
            
            if loanBase.overduePayment > 0.1 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.dateViewModel = .init(.init(longInt: nil))
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: overduePayment, title: .delay, image: Image.ic24AlertCircle, foregraund: .buttonPrimary, background: .clear, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openBottomSheet"), object: nil, userInfo: nil)
                })]
                self.secondButtonsViewModel = [ .init(amount: totalDebtAmount, title: .totalDebt ,image: nil, foregraund: .white,  background: .clear, action: {}), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
            }
            
            if loanBase.availableExceedLimit == 0 {
                
                self.headerView = .init(subTitle: .paid, collapsed: false)
                self.dateViewModel = .init(.init(longInt: nil))
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
                
            }
            
            if loanBase.minimumPayment <= 0.1, loanBase.overduePayment <= 0.1 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.dateViewModel = .init(.init(longInt: nil))
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: "Внесен", title: .minimal, image: Image.ic24Check, foregraund: .white, background: .textPrimary, action: {
                    
                }), .init(amount: totalDebtAmount, title: .totalDebt, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
            }
            
            if loanBase.gracePeriodPayment > 0.1, loanBase.minimumPayment > 0.1 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.dateViewModel = .init(.init(longInt: nil))
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = [.init(amount: totalDebtAmount, title: .totalDebt, image: nil, foregraund: .white, background: .clear, action: {})]
            }
            
            if loanBase.ownFunds > 0 {
                
                self.headerView = .init(subTitle: .paid, collapsed: false)
                self.dateViewModel = nil
                self.amountViewModel = [.init(title: .ownfunds, foregraundColor: .white, amount: ownFunds, availebelAmount: nil), .init(title: .limit, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                
                self.footerViewModel = [.init(amount: ownFunds, title: .available, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
            }
            
            if loanBase.overduePayment == 0, loanBase.gracePeriodPayment == 0, loanBase.ownFunds < 0.1 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.dateViewModel = .init(.init(longInt: nil))
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: totalDebtAmount, title: .totalDebt, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
                
            }
            
            if loanBase.overduePayment == 0, loanBase.gracePeriodPayment >= 0, loanBase.debtAmount > 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.dateViewModel = .init(.init(longInt: nil))
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
                self.secondButtonsViewModel = nil
            }
            
            if loanBase.overduePayment > 0, loanBase.gracePeriodPayment >= 0, loanBase.debtAmount > 0 {
                
                self.headerView = .init(subTitle: .interval, collapsed: false)
                self.dateViewModel = .init(.init(longInt: nil))
                self.amountViewModel = [.init(title: .debt, foregraundColor: .mainColorsBlackMedium, amount: debtAmount, availebelAmount: nil), .init(title: .available, foregraundColor: .buttonPrimary, amount: availableExceedLimit, availebelAmount: totalAvailableAmount)]
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimal, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }), .init(amount: overduePayment, title: .delay, image: Image.ic24AlertCircle, foregraund: .buttonPrimary, background: .clear, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openBottomSheet"), object: nil, userInfo: nil)
                })]
                self.secondButtonsViewModel = [ .init(amount: totalDebtAmount, title: .totalDebt ,image: nil, foregraund: .white,  background: .clear, action: {}), .init(amount: gracePeriodPayment, title: .preferential, image: nil, foregraund: .white, background: .clear, action: {})]
            }
            
            if isCredit, loanBase.overduePayment > 0.1 {
                
                if let productName = productName, productName.contains(CreditType.consumer.rawValue) {
                    
                    self.headerView = .init(subTitle: .consumer, collapsed: false)
                } else {
                    
                    self.headerView = .init(subTitle: .mortgage, collapsed: false)
                }
                
                self.dateViewModel = .init(.init(longInt: longInt))
                
                self.amountViewModel = [.init(title: .creditAmount, foregraundColor: .mainColorsBlackMedium, amount: totalDebtAmount, availebelAmount: nil), .init(title: .repaid, foregraundColor: .buttonPrimary, amount: totalAvailableAmount, availebelAmount: nil)]
                self.circleViewModel = .init(debt: loanBase.totalDebtAmount, ownFound: loanBase.ownFunds, available: loanBase.totalAvailableAmount)
                self.footerViewModel = []
                
                self.footerViewModel?.append(.init(amount: minimumPayment, title: .minimalCredit, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                }))
                
                self.footerViewModel?.append(.init(amount: " \(overduePayment)", title: .delay, image: Image.ic24AlertCircle, foregraund: .buttonPrimary, background: .clear, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openBottomSheet"), object: nil, userInfo: nil)

                }))
                
                self.secondButtonsViewModel = nil
            }
            
            if isCredit, loanBase.overduePayment <= 0 {
                
                if let productName = productName, productName.contains(CreditType.consumer.rawValue) {
                    
                    self.headerView = .init(subTitle: .consumer, collapsed: false)
                } else {
                    
                    self.headerView = .init(subTitle: .mortgage, collapsed: false)
                }
                
                self.dateViewModel = .init(.init(longInt: longInt))
                
                self.amountViewModel = [.init(title: .creditAmount, foregraundColor: .mainColorsBlackMedium, amount: totalDebtAmount, availebelAmount: nil), .init(title: .repaid, foregraundColor: .buttonPrimary, amount: totalAvailableAmount, availebelAmount: nil)]
                self.circleViewModel = .init(debt: loanBase.totalDebtAmount, ownFound: loanBase.ownFunds, available: loanBase.totalAvailableAmount)
                self.footerViewModel = [.init(amount: minimumPayment, title: .minimalCredit, image: nil, foregraund: .white, background: .textPrimary, action: {
                    NotificationCenter.default.post(name: NSNotification.Name("openPaymentsView"), object: nil, userInfo: nil)
                })]
                self.secondButtonsViewModel = nil
            }
            
            bind()
        }
        
        convenience init(with loanBase: LoanBaseParamModel, status: StatusPC, isCredit: Bool, productName: String?, longInt: Int?) {
            
            let currency = loanBase.currencyCode
            let availableExceedLimit = loanBase.availableExceedLimit.fullCurrencyFormatter(symbol: currency)
            let minimumPayment = loanBase.minimumPayment.fullCurrencyFormatter(symbol: currency)
            let gracePeriodPayment = loanBase.gracePeriodPayment.fullCurrencyFormatter(symbol: currency)
            let overduePayment = loanBase.overduePayment.fullCurrencyFormatter(symbol: currency)
            let ownFunds = loanBase.ownFunds.fullCurrencyFormatter(symbol: currency)
            let debtAmount = loanBase.debtAmount.fullCurrencyFormatter(symbol: currency)
            let totalAvailableAmount = loanBase.totalAvailableAmount.fullCurrencyFormatter(symbol: currency)
            let totalDebtAmount = loanBase.totalDebtAmount.fullCurrencyFormatter(symbol: currency)
            let isCredit = isCredit
            let longInt = longInt
            
            self.init(with: loanBase, status: status, availableExceedLimit: availableExceedLimit, minimumPayment: minimumPayment, gracePeriodPayment: gracePeriodPayment, overduePayment: overduePayment, ownFunds: ownFunds, debtAmount: debtAmount, totalAvailableAmount: totalAvailableAmount, totalDebtAmount: totalDebtAmount, isCredit: isCredit, productName: productName, longInt: longInt)
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

struct DetailAccountViewComponent: View {
    
    @ObservedObject var viewModel: DetailAccountViewComponent.ViewModel
    
    var body: some View {
        
        VStack {
            
            if viewModel.headerView.collapsed {
                
                HeaderView(viewModel: $viewModel.headerView)
                    .padding(.horizontal, 20)
                
                if let dateProgress = viewModel.dateViewModel {
                    
                    DateProgressView(viewModel: dateProgress)
                        .padding(.horizontal, 20)
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
                    
                    DateProgressView(viewModel: dateProgress)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 18)
        .background(Color.mainColorsBlack)
        .cornerRadius(12)
    }
    
    struct HeaderView: View {
        
        @Binding var viewModel: DetailAccountViewComponent.ViewModel.HeaderViewModel
        
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
    
    struct DateProgressView: View {
        
        var viewModel: ViewModel.DateViewModel?
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 12) {
                
                HStack {
                    
                    if let creditDate = viewModel?.creditDate {
                        
                        Text(creditDate)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    } else if let date = viewModel?.date {
                        
                        Text(date)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    
                    Spacer()
                    
                    Image.ic24HistoryInactive
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 12, height: 12)
                    
                    if let lostDays = viewModel?.lostDays {
                        
                        Text(lostDays)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    
                    GeometryReader { geometry in
                        
                        ZStack(alignment: .trailing) {
                            
                            Rectangle()
                                .border(Color.textPrimary, width: 1)
                                .frame(width: geometry.size.width, height: 6, alignment: .center)
                                .cornerRadius(90)
                                .background(Color.clear)
                                .foregroundColor(Color.clear)
                            
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: .init(colors: [Color(hex: "22C183"), Color(hex: "FFBB36") ,Color(hex: "FF3636")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(90)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 2)
                            
                            VStack {
                                
                                ZStack(alignment: .trailing) {
                                    
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: .init(colors: [Color.mainColorsBlack, Color.mainColorsBlack]),
                                            startPoint: .trailing,
                                            endPoint: .leading
                                        ))
                                        .frame(width: geometry.size.width * (1.0 - (viewModel?.value ?? 0.0)), height: 2)
                                        .cornerRadius(90)
                                    
                                    VStack(alignment: .trailing) {
                                        
                                        CustomLineShapeWithAlignment(stratPoint: .trailing, endPoint: .leading)
                                            .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round, miterLimit: .leastNonzeroMagnitude, dash: [1, 8], dashPhase: 3.0))
                                            .frame(height: 1.0)
                                            .foregroundColor(Color.textPrimary)
                                            .frame(width: geometry.size.width * (1.0 - (viewModel?.value ?? 0.0)))
                                    }
                                }
                                
                            }
                            .padding(.trailing, 2)
                        }
                        .frame(width: geometry.size.width, height: 6)
                    }
                }
                .frame(height: 10)
            }
        }
    }
    
    struct MainBlock: View {
        
        let viewModel: DetailAccountViewComponent.ViewModel
        
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
                            
                            DetailAccountSegmentedBar(values: [available, ownFound], totalDebt: nil, colors: [.buttonPrimary, .white])
                            
                        } else if let debt = viewModel.circleViewModel?.debt, let available = viewModel.circleViewModel?.available {
                            
                            DetailAccountSegmentedBar(values: [available, debt], totalDebt: debt, colors: [.buttonPrimary, .cardInfinite])
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
        
        var viewModel: DetailAccountViewComponent.ViewModel.AmountViewModel
        
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
        
        var viewModel: [DetailAccountViewComponent.ViewModel.FooterViewModel?]
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

struct DetailAccountComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            DetailAccountViewComponent(viewModel: .start)
                .previewLayout(.fixed(width: 375, height: 300))
            
            DetailAccountViewComponent(viewModel: .collapsed)
                .previewLayout(.fixed(width: 375, height: 300))
            
            DetailAccountViewComponent(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 300))
            
            DetailAccountViewComponent(viewModel: .full)
                .previewLayout(.fixed(width: 375, height: 300))
            
            DetailAccountViewComponent(viewModel: .fullwithButton)
                .previewLayout(.fixed(width: 375, height: 400))
        }
    }
}

extension DetailAccountViewComponent.ViewModel {
    
    static let start = DetailAccountViewComponent.ViewModel(with: .init(with: nil), status: .notActivated, isCredit: false, productName: nil, longInt: nil)
    
    static let sample = DetailAccountViewComponent.ViewModel(with: .init(with: nil), status: .notActivated, isCredit: false, productName: nil, longInt: nil)
    
    static let collapsed = DetailAccountViewComponent.ViewModel(with: .init(with: nil), status: .notActivated, isCredit: false, productName: nil, longInt: nil)
    
    static let full = DetailAccountViewComponent.ViewModel(with: .init(with: nil), status: .notActivated, isCredit: false, productName: nil, longInt: nil)
    
    static let fullwithButton = DetailAccountViewComponent.ViewModel(with: .init(with: nil), status: .notActivated, isCredit: false, productName: nil, longInt: nil)
    
}
