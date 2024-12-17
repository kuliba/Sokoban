//
//  OpenDepositDetailView.swift
//  ForaBank
//
//  Created by Дмитрий on 06.05.2022.
//

import SwiftUI
import Combine

struct OpenDepositDetailView: View {
    
    @ObservedObject var viewModel: OpenDepositDetailViewModel
    let getUImage: (Md5hash) -> UIImage?
    
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
                .padding(.bottom, 60)
            }
            if #available(iOS 15, *){
                
                Color.clear
                    .frame(height: 100)
                    .background(.ultraThinMaterial)
            } else {
               
                Color.white
                    .frame(height: 100)
                    .opacity(0.7)
            }

            Button(action: viewModel.confirmButtonTapped) {
                
                Text("Продолжить")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .frame(width: 336, height: 48)
                    .background(Color.buttonPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom, 39)
            }

            DepositShowBottomSheetView(viewModel: viewModel.calculator.bottomSheet)
        }
        .navigationBarTitle(Text("Подробнее"), displayMode: .inline)
        .foregroundColor(.black)
        .edgesIgnoringSafeArea(.bottom)
        .alert(
            item: viewModel.route.modal?.alert,
            content: alertContent
        )
        .navigationDestination(
            item: .init(
                get: { viewModel.route.destination },
                set: { if $0 == nil { viewModel.resetDestination() }}
            ),
            content: destinationView
        )
    }
    
    private func alertContent(
        _ viewModel: Alert.ViewModel
    ) -> Alert {
        
        .init(with: viewModel)
    }

    @ViewBuilder
    private func destinationView(
        destination: OpenDepositDetailViewModel.Route.Link
    ) -> some View {
        
        switch destination {
        case let .confirm(viewModel):
            ConfirmView(viewModel: viewModel, getUImage: getUImage)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle("Подтвердите параметры вклада", displayMode: .inline)
        }
    }
}

extension OpenDepositDetailView {
    
    struct HeaderView: View {
        
        let viewModel: OpenDepositDetailViewModel.ProductDetailViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 24) {
                
                HStack(spacing: 20) {
                    
                    ZStack {
                        
                        Circle()
                            .frame(width: 48, height: 48, alignment: .center)
                            .foregroundColor(.white)
                        
                        viewModel.productImage
                    }.accessibilityIdentifier("OpenDepositDetailHeaderIcon")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(viewModel.title)
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        
                        Text(viewModel.name)
                            .foregroundColor(.mainColorsBlack)
                            .font(.system(size: 24))
                            .fontWeight(.semibold)
                            .accessibilityIdentifier("OpenDepositDetailProductTitle")
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
            
            let viewModel: OpenDepositDetailViewModel.ProductDetailViewModel.Details
            
            var body: some View {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.title)
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    
                    Text(viewModel.description)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 16))
                        .accessibilityIdentifier("OpenDepositDetailItemText")
                    
                }
            }
        }
    }
    
    struct PercentView: View {
        
        @ObservedObject var viewModel: OpenDepositDetailViewModel.PercentsViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 10) {
                
                HeaderSectionView(viewModel: viewModel)
                    .padding(.horizontal, 12)
                
                if viewModel.collapsed == false {
                    
                    Text(viewModel.description)
                        .font(.system(size: 14))
                        .padding(.bottom, 6)
                        .padding(.horizontal, 12)
                        .accessibilityIdentifier("OpenDepositDetailPercentDescription")
                    
                    TableView(viewModel: viewModel.table)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 16)
            .padding(.bottom, viewModel.collapsed ? 16 : 8)
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(12)
        }
        
        struct HeaderSectionView: View {
            
            @ObservedObject var viewModel: OpenDepositDetailViewModel.PercentsViewModel
            
            var body: some View {
                
                HStack {
                    
                    Text(viewModel.title)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("OpenDepositDetailPercentTitle")
                    
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
                    .accessibilityIdentifier("OpenDepositDetailPercentCollapseButton")
                }
            }
        }
        
        struct TableView: View {
            
            let viewModel: OpenDepositDetailViewModel.PercentsViewModel.Table
            
            var body: some View {
                
                HStack(spacing: 0) {
                    
                    AmountsView(viewModel: viewModel.amounts)
                        .frame(width: 90)

                    TermsView(viewModel: viewModel.terms)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, lineWidth: 2)
                )
            }
        }
        
        struct AmountsView: View {
            
            let viewModel: OpenDepositDetailViewModel.PercentsViewModel.Amounts
            
            var body: some View {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textPlaceholder)
                        .padding(.leading, 12)
                        .padding(.top, 6)
                        .frame(height: 80, alignment: .topLeading)
                    
                    ForEach(viewModel.rows){ row in
                        
                        RowView(viewModel: row)
                            .frame(height: 48)
                            .accessibilityIdentifier("OpenDepositDetailPercentTableAmount")
                        
                    }
                }
                .background(Color.white)
            }
        }
        
        struct TermsView: View {
            
            let viewModel: OpenDepositDetailViewModel.PercentsViewModel.Terms
            
            var body: some View {
                
                ZStack(alignment: .top) {
                    
                    // back stripes
                    VStack(spacing: 0) {
                        
                        Color.clear
                            .frame(height: 34)
                            .padding(.leading, 12)
                            .padding(.bottom, 6)
                            .accessibilityIdentifier("OpenDepositDetailPercentTableTerm")
                        
                        
                        ForEach(viewModel.stripes) { stripe in
                            
                            Rectangle()
                                .foregroundColor(stripe.isEven ? Color.mainColorsGrayLightest : Color.white)
                                .frame(height: 48)
                        }
                        
                    }.padding(.top, 40)
                    
                    // numbers
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 0) {
                            
                            ForEach(viewModel.columns) { column in
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        
                                        Text(column.title)
                                            .font(.textBodyMR14180())
                                            .foregroundColor(.textSecondary)
                                        
                                        Text(column.subtitle)
                                            .font(.textBodySR12160())
                                            .foregroundColor(.textPlaceholder)
                                    }
                                    .frame(height: 34)
                                    .padding(.leading, 12)
                                    .padding(.bottom, 6)
                                    
                                    ForEach(column.rows){ row in
                                        
                                        RowView(viewModel: row)
                                            .frame(width: 90, height: 48)
                                            .accessibilityIdentifier("OpenDepositDetailPercentTablePercents")
                                    }
                                }
                            }
                        }
                        .padding(.top, 40)
                    }
                    
                    // header
                    HStack {
                        
                        Text(viewModel.title)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textPlaceholder)
                        
                        Spacer()
                        
                        if viewModel.isIconPresented {
                            
                            Image.ic16MaximizeArrow
                                .renderingMode(.template)
                                .foregroundColor(.mainColorsGrayMedium)
                                .rotationEffect(.degrees(45))
                        }
                        
                    } .padding(.horizontal, 12)
                        .padding(.top, 6)
                }
                .background(Color.white)
                .padding(.leading, 2)
            }
        }
        
        struct RowView: View {
            
            let viewModel: OpenDepositDetailViewModel.PercentsViewModel.Row
            
            var body: some View {
                
                ZStack(alignment: .leading) {
                    
                    Rectangle()
                        .foregroundColor(viewModel.isEven ? Color.mainColorsGrayLightest : Color.white)
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textSecondary)
                        .padding(.leading, 12)
                }
            }
        }
    }
    
    struct DetailView: View {
        
        let viewModel: [OpenDepositDetailViewModel.DetailsViewModel]
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 10) {
                
                ForEach(viewModel, id: \.self) { item in
                    
                    HStack(alignment: .top, spacing: 15) {
                        
                        if item.enable {
                            
                            Image.ic24Check
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .top)
                                .foregroundColor(Color.green)
                                .accessibilityIdentifier("OpenDepositDetailDetailIconEnabled")
                            
                            Text(item.title)
                                .foregroundColor(.mainColorsBlack)
                                .font(.system(size: 16))
                                .accessibilityIdentifier("OpenDepositDetailDetailTextEnabled")
                            
                        } else {
                            
                            Image.ic24Close
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .top)
                                .foregroundColor(.mainColorsGray)
                                .accessibilityIdentifier("OpenDepositDetailDetailIconDisabled")
                            
                            Text(item.title)
                                .foregroundColor(.mainColorsGray)
                                .font(.system(size: 16))
                                .accessibilityIdentifier("OpenDepositDetailDetailTextDisabled")
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
        
        @ObservedObject var viewModel: OpenDepositDetailViewModel.ConditionViewModel
        
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
                                    .accessibilityIdentifier("OpenDepositDetailConditionPoint")
                                
                                Text(item)
                                    .foregroundColor(.mainColorsBlack)
                                    .font(.system(size: 16))
                                    .accessibilityIdentifier("OpenDepositDetailConditionText")
                                
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
            
            @ObservedObject var viewModel: OpenDepositDetailViewModel.ConditionViewModel
            
            var body: some View {
                
                HStack {
                    
                    Text(viewModel.title)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("OpenDepositDetailConditionTitle")
                    
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
                    }.accessibilityIdentifier("OpenDepositDetailConditionCollapseButton")
                }
            }
        }
    }
    
    struct DocumentView: View {
        
        @ObservedObject var viewModel: OpenDepositDetailViewModel.DocumentsViewModel
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 20) {
                
                HeaderSectionView(viewModel: viewModel)
                
                if !viewModel.collapsed {
                    
                    ForEach(viewModel.documents, id: \.self) { item in
                        
                        Link(destination: item.url) {
                            
                            HStack(alignment: .top, spacing: 16) {
                                
                                Image.ic24FileText
                                    .resizable()
                                    .frame(width: 24, height: 24, alignment: .top)
                                    .foregroundColor(.mainColorsGray)
                                    .accessibilityIdentifier("OpenDepositDetailDocumentIcon")
                                
                                Text(item.title)
                                    .foregroundColor(.mainColorsBlack)
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.leading)
                                    .accessibilityIdentifier("OpenDepositDetailDocumentText")
                                
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
            
            @ObservedObject var viewModel: OpenDepositDetailViewModel.DocumentsViewModel
            
            var body: some View {
                
                HStack {
                    
                    Text(viewModel.title)
                        .foregroundColor(.mainColorsBlack)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("OpenDepositDetailDocumentTitle")
                    
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
                    }.accessibilityIdentifier("OpenDepositDetailDocumentCollapseButton")
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
    
    //FIXME: refactor all this!!!
    struct ConfirmView: UIViewControllerRepresentable {
        
        @ObservedObject var viewModel: OpenDepositDetailViewModel
        let getUImage: (Md5hash) -> UIImage?
        
        typealias UIViewControllerType = ConfurmOpenDepositViewController
        
        func makeUIViewController(context: Context) -> ConfurmOpenDepositViewController {
            
            let vc = ConfurmOpenDepositViewController()
            vc.getUImage = getUImage
            //FIXME: remove force unwrap!!!
            let deposit = viewModel.model.deposits.value.first(where: { $0.depositProductID == viewModel.id })!
            
            vc.product = proxyDepositProductData(data: deposit)
            
            var termRateSumTermRateList: [TermRateSumTermRateList] = []
            var termRateSumTermRateListCap: [TermRateSumTermRateList] = []
            
            for i in viewModel.model.deposits.value.first(where: { $0.depositProductID == viewModel.id })!.termRateList {
                
                if let termList = i.termRateSum
                    .compactMap({$0})
                    .last(where: { point in
                        point.sum <= viewModel.calculator.calculateAmount.value
                    }) {
                    
                    for point in termList.termRateList {
                        
                        termRateSumTermRateList.append(.init(term: point.term, rate: point.rate, termName: point.termName, termABS: point.termABS, termKind: point.termKind, termType: point.termType))
                    }
                }
            }
            
            vc.choosenRateList = termRateSumTermRateList
            
            if let capitalization = viewModel.calculator.capitalization, capitalization.isOn, let capList = viewModel.model.deposits.value.first(where: { $0.depositProductID == viewModel.id })!.termRateCapList {
                
                for i in capList {
                    
                    if let termList = i.termRateSum
                        .compactMap({$0})
                        .last(where: { point in
                            point.sum <= viewModel.calculator.calculateAmount.value
                        }) {
                        
                        for point in termList.termRateList {
                            
                            termRateSumTermRateListCap.append(.init(term: point.term, rate: point.rate, termName: point.termName, termABS: point.termABS, termKind: point.termKind, termType: point.termType))
                        }
                    }
                }
                vc.choosenRateListWithCap = termRateSumTermRateListCap
                vc.withCapRate = true
            }
            
            vc.depositModels = viewModel.calculator.depositModels
            
            vc.startAmount = viewModel.calculator.calculateAmount.value
            vc.bottomView.amountTextField.text = "\(viewModel.calculator.calculateAmount.value)"
            
            let termAbs = termRateSumTermRateList.first(where: {$0.termName == viewModel.calculator.bottomSheet.selectedItem.termName})?.termABS
            let rate = termRateSumTermRateList.first(where: {$0.termName == viewModel.calculator.bottomSheet.selectedItem.termName})?.rate
            let termKind = termRateSumTermRateList.first(where: {$0.termName == viewModel.calculator.bottomSheet.selectedItem.termName})?.termKind
            let termType = termRateSumTermRateList.first(where: {$0.termName == viewModel.calculator.bottomSheet.selectedItem.termName})?.termType
            
            vc.choosenRate = .init(term: viewModel.calculator.bottomSheet.selectedItem.term, rate: rate, termName: viewModel.calculator.bottomSheet.selectedItem.termName, termABS: termAbs, termKind: termKind, termType: termType)
            
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

extension OpenDepositDetailView {
    
    struct OpenProductAction: Action {}
}

struct ProductDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            OpenDepositDetailView(viewModel: .sample, getUImage: { _ in nil })
            
            OpenDepositDetailView.PercentView(viewModel: OpenDepositDetailViewModel.percentSample)
                .padding(.horizontal, 20)
        }
    }
    
}

extension OpenDepositDetailViewModel {
    
    static let conditionsSample = OpenDepositDetailViewModel.ConditionViewModel(conditions: ["Вклад открывается в системе дистанционного банковского обслуживания (ДБО) путем перевода клиентом денежных средств с его текущего счета либо счета банковской карты, открытого в Банке, на счет вклада. Вклад открывается в рублях РФ;", "Минимальная сумма вклада – 5 000 рублей;", "Максимальная сумма вклада – без ограничений;", "Срок вклада от 31 дня до 730 дней", "Процентная ставка зависит от Срока вклада;", "Выплата процентов производится в конце срока вклада;", "Для вкладов сроком 182 дня и более предусмотрены дополнительные взносы в течение первых 92 дней Срока вклада. Минимальная сумма дополнительного взноса – 2000 рублей РФ;", "При досрочном расторжении договора выплата процентов осуществляется по ставке вклада «до востребования», действующей в Банке на момент расторжения договора;", "Пролонгация по вкладу не предусмотрена;", "При невостребовании Вкладчиком; суммы вклада по окончании Срока вклада договор считается продленным на условиях вклада «до востребования»."])
    
    static let documentsSample = OpenDepositDetailViewModel.DocumentsViewModel(documents: [.init(title: "Условия комплексного банковского обслуживания", url: .init(fileURLWithPath: "")), .init(title: "Условия срочного банковского вклада СБЕРЕГАТЕЛЬНЫЙ ОНЛАЙН", url: .init(fileURLWithPath: ""))])
    
    static let detailsSample = [ OpenDepositDetailViewModel.DetailsViewModel(enable: false, title: "Прибавления процентов ко вкладу"), OpenDepositDetailViewModel.DetailsViewModel(enable: false, title: "Перечисления процентов на карту/счет"), OpenDepositDetailViewModel.DetailsViewModel(enable: false, title: "Частичное снятие"), OpenDepositDetailViewModel.DetailsViewModel(enable: true, title: "Пополнения - от 2000 ₽ для вкладов от 6 мес. (первые три месяца)"), OpenDepositDetailViewModel.DetailsViewModel(enable: true, title: "Выплата процентов - в конце срока")]
    
    static let productDetailSample = OpenDepositDetailViewModel.ProductDetailViewModel(name: "Сберегательный онлайн", detail: [.init(title: "Срок вклада", description: "До 2х лет"), .init(title: "Процентная ставка", description: "14,25%")], minAmount: .init(title: "Минимальная сумма вклада", description: "5 000.00 RUB"))
    
    static let percentSample = OpenDepositDetailViewModel.PercentsViewModel(table: .init(amounts: .init(title: "Сумма вклада, руб.", rows: [
        .init(title: "10 000", isEven: true),
        .init(title: "1 500 000", isEven: false),
        .init(title: "3 000 000", isEven: true)]), terms:
            .init(columns: [
        .init(title: "7 мес.", subtitle: "210 дней", rows: [
            .init(title: "7,05 (7,18)", isEven: true),
            .init(title: "7,20 (7,33)", isEven: false),
            .init(title: "7,35 (7,49)", isEven: true)]),
        .init(title: "12 мес.", subtitle: "365 дней", rows: [
            .init(title: "6,55 (6,75)", isEven: true),
            .init(title: "6,70 (6,91)", isEven: false),
            .init(title: "6,85 (7,07)", isEven: true)]),
        .init(title: "18 мес.", subtitle: "540 дней", rows: [
            .init(title: "6,50 (6,81)", isEven: true),
            .init(title: "6,65 (6,97)", isEven: false),
            .init(title: "6,80 (7,14)", isEven: true)])
    ])))
    
    static let percentSampleTwoRows = OpenDepositDetailViewModel.PercentsViewModel(table: .init(amounts: .init(title: "Сумма вклада, руб.", rows: [
        .init(title: "10 000", isEven: true),
        .init(title: "1 500 000", isEven: false),
        .init(title: "3 000 000", isEven: true)]), terms: .init(columns: [
        .init(title: "7 мес.", subtitle: "210 дней", rows: [
            .init(title: "7,05 (7,18)", isEven: true),
            .init(title: "7,20 (7,33)", isEven: false),
            .init(title: "7,35 (7,49)", isEven: true)]),
        .init(title: "12 мес.", subtitle: "365 дней", rows: [
            .init(title: "6,55 (6,75)", isEven: true),
            .init(title: "6,70 (6,91)", isEven: false),
            .init(title: "6,85 (7,07)", isEven: true)])
    ])))
        
    static let sample = OpenDepositDetailViewModel(id: 0, productDetail: productDetailSample, calculator: .sample1, details: detailsSample, documents: documentsSample, condition: conditionsSample, percents: percentSample, makeAlertViewModel: { .disableForCorporateCard(primaryAction: $0)})
}
