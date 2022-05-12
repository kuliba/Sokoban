//
//  ProductDetailView.swift
//  ForaBank
//
//  Created by Дмитрий on 06.05.2022.
//

import SwiftUI
import Combine

class OpenProductViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let model: Model = .shared
    let productDetail: ProductDetailViewModel
    var calculator:  DepositCalculatorViewModel
    let details: [DetailsViewModel]
    let documents: DocumentViewModel
    let condition: ConditionViewModel
    let percents: PercentsViewModel?
    var depositId = 0
    
    init(productDetail: ProductDetailViewModel, calculator: DepositCalculatorViewModel, details: [DetailsViewModel], documents: DocumentViewModel, condition: ConditionViewModel, percents: PercentsViewModel?) {
        
        self.productDetail = productDetail
        self.calculator = calculator
        self.details = details
        self.documents = documents
        self.condition = condition
        self.percents = percents
        
    }
    
    init(depositId: Int) {
        
        self.depositId = depositId
        let deposit = model.depositsProducts.value.first(where: { $0.depositProductID == depositId })!
        
        self.productDetail = .init(name: deposit.name, detail: [.init(title: "Срок вклада", description: deposit.generalСondition.maxTermTxt), .init(title: "Процентная ставка", description: "до \(deposit.generalСondition.maxRate.currencyFormatterForMain()) %")], minAmount: .init(title: "Минимальная  сумма вклада", description: deposit.generalСondition.minSum.currencyFormatter()))
        
        if let termRateCapList = deposit.termRateCapList {
            
            self.calculator = DepositCalculatorViewModel.init(depositModels: .init(points: reduceModels(with: deposit)), capitalization: .sample, calculateAmount: .init(interestRateValue: deposit.termRateList[0].termRateSum[0].termRateList[0].rate, depositValue: Int(deposit.generalСondition.minSum),minSum: deposit.generalСondition.minSum, bounds: deposit.generalСondition.minSum...deposit.generalСondition.maxSum), bottomSheet: .init(items: .init(reduceBottomSheetItem(with: deposit.termRateList[0].termRateSum))))
            
        } else {
            
            self.calculator = DepositCalculatorViewModel(depositModels: .init(points: reduceModels(with: deposit)), capitalization: nil, calculateAmount: .init(interestRateValue: deposit.termRateList[0].termRateSum[0].termRateList[0].rate, depositValue: Int(deposit.generalСondition.minSum),minSum: deposit.generalСondition.minSum, bounds: deposit.generalСondition.minSum...deposit.generalСondition.maxSum), bottomSheet: .init(items: .init(reduceBottomSheetItem(with: deposit.termRateList[0].termRateSum))))
        }
        
        func reduceBottomSheetItem(with deposit: [DepositProductData.TermCurrencyRate.TermRateSum]) -> [DepositBottomSheetItemViewModel] {
            
            var items: [DepositBottomSheetItemViewModel] = []
            
            for item in deposit {
                for i in item.termRateList {
                    
                    items.append(.init(term: i.term, rate: i.rate, termName: i.termName))
                }
            }
            
            return items
        }
        
        func reduceModels(with deposit: DepositProductData) -> [DepositCalculatorViewModel.DepositInterestRatePoint] {
            
            var points: [DepositCalculatorViewModel.DepositInterestRatePoint] = []
            
            var point: [DepositBottomSheetItemViewModel] = []
            var capPoint: [DepositBottomSheetItemViewModel] = []
            var sum: Double = 0.0
            
            for termRateList in deposit.termRateList[0].termRateSum {
                
                sum = termRateList.sum
                point = []
                capPoint = []
                
                for i in termRateList.termRateList {
                    
                    point.append(.init(term: i.term, rate: i.rate, termName: i.termName))
                    
                    if let capList = deposit.termRateCapList {
                        
                        for capList in capList[0].termRateSum {
                            
                            for i in capList.termRateList {
                                
                                capPoint.append(.init(term: i.term, rate: i.rate, termName: i.termName))
                            }
                            
                            points.append(.init(minSumm: sum, termRateLists: point, termRateCapLists: capPoint))
                            
                        }
                        
                    } else {
                        
                        points.append(.init(minSumm: sum, termRateLists: point, termRateCapLists: capPoint))
                    }
                }
            }
            
            return points
        }
        
        self.details = reduceDetail(deposit: deposit)
        self.documents = .init(documents: reduceDocument(documents: deposit.documentsList))
        self.condition = .init(conditions: deposit.txtСondition)
        
        let date = deposit.termRateList[0].termRateSum[0].termRateList.map({$0.termName})
        
        if let termRateCapList = deposit.termRateCapList {
            
            self.percents = .init(termRateSum: reduceTermRateList(with: deposit), date: date)
        } else {
            
            self.percents = nil
        }
        
        func reduceTermRateList(with deposit: DepositProductData) -> [PercentsViewModel.TermRateSum] {
            
            var term: [PercentsViewModel.TermRateSum] = []
            var capRate: [String] = []
            var rate: [String] = []
            var sum: [String] = []
            var mergedString: [String] = []
            var mergedString2: [[String]] = []
            
            for item in deposit.termRateList {
                
                for termRateSum in item.termRateSum {
                    sum.append(termRateSum.sum.fullCurrencyFormatter())
                    rate = rate + termRateSum.termRateList.map({String($0.rate)})
                    
                }
            }
            
            if let termRateCapList = deposit.termRateCapList {
                
                for item in termRateCapList {
                    
                    for termRateSum in item.termRateSum {
                        
                        capRate = capRate + termRateSum.termRateList.map({String($0.rate)})
                        
                    }
                }
            }
            
            func mergeString(string: [String], string2: [String]) -> [String] {
                
                var strings: [String] = []
                
                for i in string.indices {
                    
                    strings.append("\(string[i])" + " " + "(\(string2[i]))")
                    
                }
                
                return strings
            }
            
            mergedString = mergeString(string: rate, string2: capRate)
            
            for i in sum.indices {
                
                let array = mergedString.splitInSubArrays(sum.count)
                term.append(.init(sum: sum[i], rate: array[i]))
            }
            
            return term
        }
        
        func reduceDetail(deposit: DepositProductData) -> [DetailsViewModel] {
            
            var details: [DetailsViewModel] = []
            
            for item in deposit.detailedСonditions {
                
                let detailItem: DetailsViewModel = .init(enable: item.enable, title: item.desc)
                details.append(detailItem)
            }
            
            return details
        }
        
        func reduceDocument(documents: [DepositProductData.DocumentsData]) -> [DocumentViewModel.Documents] {
            
            var document: [DocumentViewModel.Documents] = []
            
            for item in documents {
                document.append(.init(title: item.name, url: item.url))
            }
            
            return document
        }
    }
    
    struct ProductDetailViewModel {
        
        let title = "Наименование вклада"
        let productImage = Image.init("Deposit Icon")
        let name: String
        let detail: [Details]
        let minAmount: Details
        
        struct Details: Identifiable {
            
            var id = UUID()
            let title: String
            let description: String
        }
    }
    
    class PercentsViewModel: ObservableObject {
        
        let title = "Процентные ставки"
        let description = "В скобках указана эффективная ставка с учетом капитализации в процентах годовых."
        let minTitle = "Мин. сумма\nвклада, руб"
        let dateTitle = "Срок вклада"
        var termRateSum: [TermRateSum] = []
        var date: [String] = []
        @Published var collapsed: Bool = false
        
        struct TermRateSum: Identifiable {
            
            let id = UUID()
            let sum: String
            var rate: [String]
            
        }
        
        init(termRateSum: [TermRateSum], date: [String]) {
            self.termRateSum = termRateSum
            self.date = date
        }
    }
    
    class ConditionViewModel: ObservableObject {
        
        let title = "Условия вклада"
        let conditions: [String]
        @Published var collapsed: Bool = true
        
        init(conditions: [String]) {
            
            self.conditions = conditions
        }
        
    }
    
    class DocumentViewModel: ObservableObject {
        
        let title = "Документы"
        let documents: [Documents]
        @Published var collapsed: Bool = true
        
        init(documents: [Documents]) {
            
            self.documents = documents
        }
        
        struct Documents: Hashable {
            
            let title: String
            let url: URL
        }
    }
    
    struct DetailsViewModel: Identifiable, Hashable {
        
        let id = UUID()
        let enable: Bool
        let title: String
    }
}

struct ProductDetailView: View {
    
    @ObservedObject var viewModel: OpenProductViewModel
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
                    HeaderView(viewModel: viewModel.productDetail)
                    
                    DepositCalculatorView(viewModel: viewModel.calculator)
                    
                    if let percent = viewModel.percents {
                        
                        PercentView(viewModel: percent)
                    }
                    
                    DetailView(viewModel: viewModel.details)
                    ConditionView(viewModel: viewModel.condition)
                    DocumentView(viewModel: viewModel.documents)
                        .padding(.bottom, 50)
                }
                .padding(20)
            }
            
            NavigationLink(destination: ConfirmView(viewModel: viewModel)) {
                
                Text("Продолжить")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .frame(width: 336, height: 48)
                    .background(Color.buttonPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            DepositShowBottomSheetView(viewModel: viewModel.calculator.bottomSheet)
        }
        .navigationBarTitle(Text("Подробнее"), displayMode: .inline)
        .foregroundColor(.black)
    }
}

extension ProductDetailView {
    
    struct HeaderView: View {
        
        let viewModel: OpenProductViewModel.ProductDetailViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 24) {
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        
                        Circle()
                            .frame(width: 48, height: 48, alignment: .center)
                            .foregroundColor(.white)
                        
                        viewModel.productImage
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(viewModel.title)
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        
                        Text(viewModel.name)
                            .foregroundColor(.mainColorsBlack)
                            .font(.system(size: 24))
                            .fontWeight(.semibold)
                    }
                }
                
                HStack {
                    
                    ForEach(viewModel.detail) { item in
                        
                        DetailView(viewModel: item)
                        Spacer()
                    }
                }
                
                DetailView(viewModel: viewModel.minAmount)
            }
            .padding(20)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
        }
        
        struct DetailView: View {
            
            let viewModel: OpenProductViewModel.ProductDetailViewModel.Details
            
            var body: some View {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    
                    Text(viewModel.description)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 16))
                    
                }
            }
        }
    }
    
    struct PercentView: View {
        
        @ObservedObject var viewModel: OpenProductViewModel.PercentsViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 10) {
                
                HeaderSectionView(viewModel: viewModel)
                
                if !viewModel.collapsed {
                    
                    Text(viewModel.description)
                        .font(.system(size: 14))
                    
                    HStack(alignment: .center) {
                        
                        Text(viewModel.minTitle)
                            .foregroundColor(.textPlaceholder)
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            
                            Text(viewModel.dateTitle)
                                .foregroundColor(.textPlaceholder)
                                .font(.system(size: 12))
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 0) {
                        
                        HStack {
                            
                            Spacer()
                            
                            ForEach(viewModel.date, id: \.self) { date in
                                
                                Text(date)
                                    .padding(.trailing, 30)
                            }
                        }
                        .padding(.top, 9)
                        .padding(.bottom, 5)
                        .background(Color.white)
                        .padding(.horizontal, -20)
                        
                        ForEach(viewModel.termRateSum.indices) { index in
                            
                            if index % 2 == 0 {
                                
                                HStack {
                                    
                                    Text(viewModel.termRateSum[index].sum)
                                        .padding(.leading, 20)
                                    
                                    Spacer()
                                    
                                    ForEach(viewModel.termRateSum[index].rate, id: \.self) { item in
                                        Text(item)
                                            .padding(.trailing, 30)
                                    }
                                }
                                .padding(.top, 9)
                                .padding(.bottom, 5)
                                .background(Color.mainColorsGrayLightest)
                                .padding(.horizontal, -20)
                                
                            } else {
                                
                                HStack {
                                    
                                    Text(viewModel.termRateSum[index].sum)
                                        .padding(.leading, 20)
                                    
                                    Spacer()
                                    
                                    ForEach(viewModel.termRateSum[index].rate, id: \.self) { item in
                                        Text(item)
                                            .padding(.trailing, 30)
                                    }
                                }
                                .padding(.top, 9)
                                .padding(.bottom, 5)
                                .background(Color.white)
                                .padding(.horizontal, -20)
                            }
                        }
                    }
                    .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
        }
        
        struct HeaderSectionView: View {
            
            @ObservedObject var viewModel: OpenProductViewModel.PercentsViewModel
            
            var body: some View {
                
                HStack {
                    
                    Text(viewModel.title)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        
                        withAnimation(.easeOut){
                            viewModel.collapsed.toggle()
                        }
                        
                    } label: {
                        
                        if viewModel.collapsed {
                            
                            Image.ic16ChevronUp
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(.mainColorsGray)
                        } else {
                            
                            Image.ic16ChevronDown
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
            }
        }
    }
    
    struct DetailView: View {
        
        let viewModel: [OpenProductViewModel.DetailsViewModel]
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 10) {
                
                ForEach(viewModel, id: \.self) { item in
                    
                    HStack(alignment: .top, spacing: 15) {
                        
                        if item.enable {
                            
                            Image.ic24Check
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .top)
                                .foregroundColor(Color.green)
                            
                            Text(item.title)
                                .foregroundColor(.mainColorsBlack)
                                .font(.system(size: 16))
                            
                        } else {
                            
                            Image.ic24Close
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .top)
                                .foregroundColor(.mainColorsGray)
                            
                            Text(item.title)
                                .foregroundColor(.mainColorsGray)
                                .font(.system(size: 16))
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
        }
    }
    
    struct ConditionView: View {
        
        @ObservedObject var viewModel: OpenProductViewModel.ConditionViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 20) {
                
                HeaderSectionView(viewModel: viewModel)
                
                if !viewModel.collapsed {
                    
                    VStack(spacing: 5) {
                        
                        ForEach(viewModel.conditions, id: \.self) { item in
                            
                            HStack(alignment: .top, spacing: 10) {
                                
                                Circle()
                                    .frame(width: 4, height: 4, alignment: .top)
                                    .padding(.top, 8)
                                
                                Text(item)
                                    .foregroundColor(.mainColorsBlack)
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
        }
        
        struct HeaderSectionView: View {
            
            @ObservedObject var viewModel: OpenProductViewModel.ConditionViewModel
            
            var body: some View {
                
                HStack {
                    
                    Text(viewModel.title)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        
                        withAnimation(.easeOut){
                            viewModel.collapsed.toggle()
                        }
                        
                    } label: {
                        
                        if viewModel.collapsed {
                            
                            Image.ic16ChevronUp
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(.mainColorsGray)
                        } else {
                            
                            Image.ic16ChevronDown
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
            }
        }
    }
    
    struct DocumentView: View {
        
        @ObservedObject var viewModel: OpenProductViewModel.DocumentViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 20) {
                
                HeaderSectionView(viewModel: viewModel)
                
                if !viewModel.collapsed {
                    
                    ForEach(viewModel.documents, id: \.self) { item in
                        
                        if #available(iOS 14.0, *) {
                            
                            Link(destination: item.url) {
                                
                                HStack(alignment: .top, spacing: 16) {
                                    
                                    Image.ic24FileText
                                        .resizable()
                                        .frame(width: 24, height: 24, alignment: .top)
                                        .foregroundColor(.mainColorsGray)
                                    
                                    Text(item.title)
                                        .foregroundColor(.mainColorsBlack)
                                        .font(.system(size: 16))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                }
                            }
                            
                        } else {
                            
                            ForEach(viewModel.documents, id: \.self) { item in
                                
                                Button{
                                    
                                    UIApplication.shared.open(item.url)
                                    
                                } label: {
                                    
                                    HStack(spacing: 10) {
                                        
                                        Image.ic24FileText
                                            .resizable()
                                            .frame(width: 24, height: 24, alignment: .top)
                                            .foregroundColor(.mainColorsGray)
                                        
                                        Text(item.title)
                                            .foregroundColor(.mainColorsBlack)
                                            .font(.system(size: 16))
                                        
                                        Spacer()
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
        }
        
        struct HeaderSectionView: View {
            
            @ObservedObject var viewModel: OpenProductViewModel.DocumentViewModel
            
            var body: some View {
                
                HStack {
                    
                    Text(viewModel.title)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        
                        withAnimation(.easeOut){
                            viewModel.collapsed.toggle()
                        }
                        
                    } label: {
                        
                        if viewModel.collapsed {
                            
                            Image.ic16ChevronUp
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(.mainColorsGray)
                        } else {
                            
                            Image.ic16ChevronDown
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
            }
        }
    }
    
    struct DepositShowBottomSheetView: View {
        
        @ObservedObject var viewModel: DepositBottomSheetViewModel
        
        var body: some View {
            
            DepositCalculatorView.DepositContainerBottomSheetView(
                isOpen: $viewModel.isShowBottomSheet,
                maxHeight: CGFloat(viewModel.items.count * viewModel.itemHeight)) {
                    DepositBottomSheetView(viewModel: viewModel)
                }
        }
    }
    
    struct ConfirmView: UIViewControllerRepresentable {
        
        @ObservedObject var viewModel: OpenProductViewModel
        
        typealias UIViewControllerType = ConfurmOpenDepositViewController
        
        func makeUIViewController(context: Context) -> ConfurmOpenDepositViewController {
            
            let vc = ConfurmOpenDepositViewController()
            
            vc.product = proxyDepositProductData(data: viewModel.model.depositsProducts.value.first(where: { $0.depositProductID == viewModel.depositId })!)
            
            var termRateSumTermRateList: [TermRateSumTermRateList] = []
            
            for i in viewModel.model.depositsProducts.value.first(where: { $0.depositProductID == viewModel.depositId })!.termRateList {
                
                for sum in i.termRateSum {
                    
                    for s in sum.termRateList {
                        
                        termRateSumTermRateList.append(.init(term: s.term, rate: s.rate, termName: s.termName))
                    }
                }
            }
            
            vc.choosenRateList = termRateSumTermRateList
            vc.choosenRate = .init(term: viewModel.calculator.bottomSheet.selectedItem.term, rate: viewModel.calculator.bottomSheet.selectedItem.rate, termName: viewModel.calculator.bottomSheet.selectedItem.termName)
            
            vc.startAmount = viewModel.calculator.calculateAmount.value
            vc.modalPresentationStyle = .fullScreen
            
            func proxyDepositProductData(data: DepositProductData) -> OpenDepositDatum {
                
                var openDepositDatum: OpenDepositDatum
                
                openDepositDatum = .init(depositProductID: data.depositProductID, name: data.name, generalСondition: .init(maxRate: data.generalСondition.maxRate, minSum: Int(data.generalСondition.minSum), maxSum: Int(data.generalСondition.maxSum), minTerm: data.generalСondition.minTerm, maxTerm: data.generalСondition.minTerm, maxTermTxt: data.generalСondition.maxTermTxt, imageLink: data.generalСondition.imageLink, design: nil, formula: data.generalСondition.formula, сurrencyCode: nil, generalTxtСondition: nil), detailedСonditions: nil, txtСondition: nil, termRateList: nil, termRateCapList: nil, documentsList: nil)
                
                return openDepositDatum
            }
            
            return vc
        }
        
        func updateUIViewController(_ uiViewController: ConfurmOpenDepositViewController, context: Context) {
            
        }
    }
}

extension ProductDetailView {
    
    struct OpenProductAction: Action {}
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            
            ProductDetailView(viewModel: .sample)
        }
    }
    
}

extension OpenProductViewModel {
    
    static let conditionsSample = OpenProductViewModel.ConditionViewModel(conditions: ["Вклад открывается в системе дистанционного банковского обслуживания (ДБО) путем перевода клиентом денежных средств с его текущего счета либо счета банковской карты, открытого в Банке, на счет вклада. Вклад открывается в рублях РФ;", "Минимальная сумма вклада – 5 000 рублей;", "Максимальная сумма вклада – без ограничений;", "Срок вклада от 31 дня до 730 дней", "Процентная ставка зависит от Срока вклада;", "Выплата процентов производится в конце срока вклада;", "Для вкладов сроком 182 дня и более предусмотрены дополнительные взносы в течение первых 92 дней Срока вклада. Минимальная сумма дополнительного взноса – 2000 рублей РФ;", "При досрочном расторжении договора выплата процентов осуществляется по ставке вклада «до востребования», действующей в Банке на момент расторжения договора;", "Пролонгация по вкладу не предусмотрена;", "При невостребовании Вкладчиком; суммы вклада по окончании Срока вклада договор считается продленным на условиях вклада «до востребования»."])
    
    static let documentsSample = OpenProductViewModel.DocumentViewModel(documents: [.init(title: "Условия комплексного банковского обслуживания", url: .init(fileURLWithPath: "")), .init(title: "Условия срочного банковского вклада СБЕРЕГАТЕЛЬНЫЙ ОНЛАЙН", url: .init(fileURLWithPath: ""))])
    
    static let detailsSample = [ OpenProductViewModel.DetailsViewModel(enable: false, title: "Прибавления процентов ко вкладу"), OpenProductViewModel.DetailsViewModel(enable: false, title: "Перечисления процентов на карту/счет"), OpenProductViewModel.DetailsViewModel(enable: false, title: "Частичное снятие"), OpenProductViewModel.DetailsViewModel(enable: true, title: "Пополнения - от 2000 ₽ для вкладов от 6 мес. (первые три месяца)"), OpenProductViewModel.DetailsViewModel(enable: true, title: "Выплата процентов - в конце срока")]
    
    static let productDetailSample = OpenProductViewModel.ProductDetailViewModel(name: "Сберегательный онлайн", detail: [.init(title: "Срок вклада", description: "До 2х лет"), .init(title: "Процентная ставка", description: "14,25%")], minAmount: .init(title: "Минимальная сумма вклада", description: "5 000.00 RUB"))
    
    static let percentSample = OpenProductViewModel.PercentsViewModel(termRateSum: [.init(sum: "10 000", rate: ["7,95 (8,25)", "12,00 (13,06)"]), .init(sum: "1 500 000", rate: ["7,95 (8,25)", "12,50 (13,65)"]), .init(sum: "3 000 000", rate: ["8,35 (8,68)", "13,00 (14,25)"])], date: ["365 дней", "540 дней"])
    
    static let sample = OpenProductViewModel(productDetail: productDetailSample, calculator: .sample1, details: detailsSample, documents: documentsSample, condition: conditionsSample, percents: percentSample)
}
