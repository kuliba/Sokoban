//
//  OpenDepositDetailViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 11.10.2022.
//

import SwiftUI
import Combine

class OpenDepositDetailViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let id: DepositProductData.ID
    let productDetail: ProductDetailViewModel
    let calculator:  DepositCalculatorViewModel
    let details: [DetailsViewModel]
    let documents: DocumentsViewModel
    let condition: ConditionViewModel
    let percents: PercentsViewModel?
    let makeAlertViewModel: PaymentsTransfersFactory.MakeAlertViewModel
    
    @Published private(set) var route: Route
    
    let model: Model

    init(
        id: DepositProductData.ID, 
        productDetail: ProductDetailViewModel,
        calculator: DepositCalculatorViewModel,
        details: [DetailsViewModel],
        documents: DocumentsViewModel,
        condition: ConditionViewModel,
        percents: PercentsViewModel?,
        model: Model = .emptyMock,
        route: Route = .empty,
        makeAlertViewModel: @escaping PaymentsTransfersFactory.MakeAlertViewModel
    ) {
        self.id = id
        self.productDetail = productDetail
        self.calculator = calculator
        self.details = details
        self.documents = documents
        self.condition = condition
        self.percents = percents
        self.model = model
        self.route = route
        self.makeAlertViewModel = makeAlertViewModel
    }
    
    convenience init?(
        depositId: DepositProductData.ID, 
        model: Model,
        route: Route = .empty,
        makeAlertViewModel: @escaping PaymentsTransfersFactory.MakeAlertViewModel
    ) {
        guard let deposit = model.deposits.value.first(where: { $0.depositProductID == depositId }) else {
            
            return nil
        }
        
        let productDetail = ProductDetailViewModel(with: deposit)
        let calculator = DepositCalculatorViewModel(with: deposit)
        let details = Self.reduceDetail(deposit: deposit)
        let documents = DocumentsViewModel(with: deposit)
        let condition = ConditionViewModel(conditions: deposit.txtСondition)
        let percents = PercentsViewModel(with: deposit)
        
        self.init(id: depositId, productDetail: productDetail, calculator: calculator, details: details, documents: documents, condition: condition, percents: percents, model: model, route: route, makeAlertViewModel: makeAlertViewModel)
    }
    
    struct Route {
        
        var destination: Link?
        var modal: Modal?

        static let empty: Self = .init(destination: nil)
        
        enum Link: Identifiable {
            
            case confirm(OpenDepositDetailViewModel)
            
            var id: Case {
                
                switch self {
                    
                case let .confirm(viewModel):
                    return .confirm(viewModel.id)
                }
            }
            
            enum Case: Hashable {
                
                case confirm(DepositProductData.ID)
            }
        }
    }
    
    enum Modal {
        
        case alert(Alert.ViewModel)
        
        var alert: Alert.ViewModel? {
            
            guard case let .alert(alert) = self else { return nil }
            return alert
        }
    }
    
    func resetDestination() {
        
        route.destination = nil
    }
    
    func resetModal() {
        
        route.modal = nil
    }

    func confirmButtonTapped() {
        
        if model.onlyCorporateCards, let alertViewModel = makeAlertViewModel({}) {
            
            route.modal = .alert(alertViewModel)
        }
        else {
            route.destination = .confirm(self)
        }
    }
}

//MARK :- Reducers

extension OpenDepositDetailViewModel {
    
    static func reduceDetail(deposit: DepositProductData) -> [DetailsViewModel] {
        
        var details: [DetailsViewModel] = []
        
        for item in deposit.detailedСonditions {
            
            let detailItem: DetailsViewModel = .init(enable: item.enable, title: item.desc)
            details.append(detailItem)
        }
        
        return details
    }
}

//MARK :- Types

extension OpenDepositDetailViewModel {
    
    struct ProductDetailViewModel {

        let title = "Наименование вклада"
        //FIXME: change to icon from StyleGuide
        let productImage = Image("Deposit Icon")
        let name: String
        let detail: [Details]
        let minAmount: Details
        
        internal init(name: String, detail: [Details], minAmount: Details) {
            self.name = name
            self.detail = detail
            self.minAmount = minAmount
        }

        init(with deposit: DepositProductData) {
            
            self.init(name: deposit.name, detail: [.init(title: "Срок вклада", description: deposit.generalСondition.maxTermTxt), .init(title: "Процентная ставка", description: "до \(deposit.generalСondition.maxRate.currencyFormatterForMain()) %")], minAmount: .init(title: "Минимальная  сумма вклада", description: deposit.generalСondition.minSum.currencyFormatter()))
        }
        
        struct Details: Identifiable {
            
            let id = UUID()
            let title: String
            let description: String
        }
    }
    
    class PercentsViewModel: ObservableObject {

        @Published var collapsed: Bool = false
        
        let title = "Процентные ставки"
        let description = "В скобках указана эффективная ставка с учетом капитализации в процентах годовых."
        let table: Table
        
        init(table: Table) {
            
            self.table = table
        }
        
        convenience init?(with deposit: DepositProductData) {
            
            guard let termCapRates = deposit.termRateCapList?.first,
                  let termRates = deposit.termRateList.first else {
                return nil
            }
            
            let amountsFormatter = NumberFormatter.decimalWithoutFraction
            let ratesFormatter = NumberFormatter.decimal()
            
            // zip function
            // arr1       arr2        result
            // [1, 2, 3]  [2, 3, 4]   [(1, 2), (2, 3), (3, 4)]
            
            let values = zip(termRates.termRateSum, termCapRates.termRateSum)
            var amountsRows = [Row]()
            
            var columnsTitles = [(String, String)]()
            var columnsRowsValues = [[String]]()
            
            // (Int , (TermRateSum, TermRateSum))
            for (index, (base, cap)) in values.enumerated() {
                
                let isEven = index % 2 == 0
                let amount = amountsFormatter.string(from: NSNumber(value: base.sum)) ?? String(base.sum)
                amountsRows.append(.init(title: amount, isEven: isEven))
                
                var columnValues = [String]()
                let periods = zip(base.termRateList, cap.termRateList)
                columnsTitles = [(String, String)]()
                
                for (basePeriod, capPeriod) in periods {
                    
                    let columnTite = basePeriod.monthsValue
                    let columnSubtitle = "\(basePeriod.term) дней"
                    columnsTitles.append((columnTite, columnSubtitle))
                    
                    let baseRate = ratesFormatter.string(from: NSNumber(value: basePeriod.rate)) ?? String(basePeriod.rate)
                    let capRate = ratesFormatter.string(from: NSNumber(value: capPeriod.rate)) ?? String(capPeriod.rate)
                    let rate = "\(baseRate) (\(capRate))"
                    columnValues.append(rate)
                }

                columnsRowsValues.append(columnValues)
            }
            
            // transpose function
            // source   result
            // [1, 2]   [1, 3]
            // [3, 4]   [2, 4]
            
            var columnsRows = [[Row]]()
            for columnValues in columnsRowsValues.transposed() {
                
                var rows = [Row]()
                for (index, value) in columnValues.enumerated() {
                    
                    let isEven = index % 2 == 0
                    rows.append(Row(title: value, isEven: isEven))
                }
                
                columnsRows.append(rows)
            }
            
            let columnsData = zip(columnsTitles, columnsRows)
            let columns = columnsData.map { (header, rows) -> Column in
                
                let (title, subtitle) = header
                
                return Column(title: title, subtitle: subtitle, rows: rows)
            }
            
            let amounts = Amounts(title: "Сумма вклада, \(termRates.currencyShortName)", rows: amountsRows)
            let terms = Terms(columns: columns)
            
            self.init(table: Table(amounts: amounts, terms: terms))
        }
        
        struct Table {
            
            let amounts: Amounts
            let terms: Terms
        }
        
        struct Amounts {
            
            let title: String
            let rows: [Row]
        }
        
        struct Terms {
            
            let title  = "Срок вклада"
            let columns: [Column]
            var stripes: [Stripe] {
                
                guard let firstColum = columns.first else {
                    return []
                }
                
                return firstColum.rows.map{ Stripe(isEven: $0.isEven) }
            }
            var isIconPresented: Bool { columns.count > 2 }
        }
        
        struct Column: Identifiable {
            
            let id = UUID()
            let title: String
            let subtitle: String
            let rows: [Row]
        }
        
        struct Row: Identifiable {
            
            let id = UUID()
            let title: String
            let isEven: Bool
        }
        
        struct Stripe: Identifiable {
            
            let id = UUID()
            let isEven: Bool
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
    
    class DocumentsViewModel: ObservableObject {
        
        let title = "Документы"
        let documents: [Document]
        @Published var collapsed: Bool = true
        
        init(documents: [Document]) {
            
            self.documents = documents
        }
        
        convenience init(with deposit: DepositProductData) {
            
            let documents = deposit.documentsList.map{ Document(title: $0.name, url: $0.url) }
            self.init(documents: documents)
        }
        
        struct Document: Hashable {
            
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
