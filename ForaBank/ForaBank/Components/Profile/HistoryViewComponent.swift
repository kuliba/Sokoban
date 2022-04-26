//
//  HistoryViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI
import Combine
import Shimmer

extension HistoryViewComponent {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let title = "История операций"
        @Published var listState: OperationsListState
        @Published var dateOperations: [OperationsDateViewModel]
        @Published var spendingViewModel: SegmentedBarView.ViewModel?
        @Published var isLoading = true
        let productId: Int
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(dateOperations: [OperationsDateViewModel], spendingViewModel: SegmentedBarView.ViewModel?, productId: Int, model: Model = .emptyMock) {
            
            self.dateOperations = dateOperations
            self.listState = .list(dateOperations)
            self.spendingViewModel = spendingViewModel
            self.productId = productId
            self.model = model
            
        }
        
        init(_ model: Model, productId: Int, productType: ProductType) {
            
            self.dateOperations = []
            self.spendingViewModel = nil
            self.model = model
            self.listState = .loading
            self.productId = productId
            bind()
            
            model.action.send(ModelAction.Statement.List.Request(productId: productId, productType: productType))
        }
        
        private func bind() {
            
            model.statement
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] operations in
                    
                    guard let statement = operations.productStatement[productId] else { return }
                    self.dateOperations = separationDate(operations: statement)
                    if sumDeifferentGroup(operations: statement).count > 0 {
                        
                        self.spendingViewModel = .init(value: sumDeifferentGroup(operations: statement))
                    }
                    
                    self.isLoading = false
                    if self.dateOperations.count > 0 {
                        
                        self.listState = .list(self.dateOperations)
                    } else {
                        self.listState = .error(.init(button: .init(action: { [self]_ in model.action.send(ModelAction.Statement.List.Request(productId: productId, productType: .card))})))
                    }
                    
                }.store(in: &bindings)
        }
        
        enum OperationsListState {
            
            case empty(OperationsEmptyViewModel)
            case list([OperationsDateViewModel])
            case error(OperationsErrorViewModel)
            case loading
            
        }
        
        struct OperationsEmptyViewModel {
            
            let image = Image.ic24Search
            let title = "Нет операций"
        }
        
        struct OperationsErrorViewModel {
            
            let errorTitle = "Превышено время ожидания"
            let subTitle = "Попробуйте повторить запрос позже"
            let image = Image.ic24Search
            let button: ButtonViewModel
            
            struct ButtonViewModel {
                
                let title = "Повторить"
                let action: (Action) -> Void
            }
        }
        
        struct OperationsDateViewModel: Identifiable {
            
            let id = UUID()
            let date: String
            let operations: [Operation]
            
            internal init(date: String, operations: [Operation]) {
                
                self.date = date
                self.operations = operations
            }
            
            struct Operation: Identifiable {
                
                let id = UUID()
                let title: String
                let image: Image?
                let subtitle: String
                let amount: String
                let type: OperationType
                
                internal init(title: String, image: Image?, subtitle: String, amount: String, type: OperationType) {
                    
                    self.title = title
                    self.image = image
                    self.subtitle = subtitle
                    self.amount = amount
                    self.type = type
                }
                
                init(productStatementData: ProductStatementData) {
                    
                    if let name = productStatementData.merchantNameRus {
                        
                        title = name
                    } else {
                        title = productStatementData.merchantName
                    }
                    if let image = productStatementData.svgImage.image {
                        
                        self.image = image
                    } else {
                        
                        self.image = nil
                    }
                    
                    self.subtitle = productStatementData.groupName
                    self.type = productStatementData.operationType
                    
                    self.amount = productStatementData.amountFormattedtWithCurrency
                }
            }
        }
    }
}

extension HistoryViewComponent.ViewModel {
    
    func separationDate(operations: [ProductStatementData]) -> [OperationsDateViewModel] {
        
        let groupByDate = Dictionary(grouping: operations) { (operation) -> String in
            
            let dateFormatter = DateFormatter.historyDateFormatter
            let localDate = dateFormatter.string(from: operation.tranDate)
            
            return localDate
        }
        
        let sortedArray = groupByDate.sorted(by: { $0.0 > $1.0 })
        
        var dateOperations: [OperationsDateViewModel] = []
        
        for date in sortedArray {
            
            var operations = [OperationsDateViewModel.Operation]()
            
            for operation in date.value {
                
                operations.append(OperationsDateViewModel.Operation(productStatementData: operation))
            }
            
            dateOperations.append(OperationsDateViewModel(date: date.key, operations: operations))
        }
        
        return dateOperations
    }
    
    func sumDeifferentGroup(operations: [ProductStatementData]) -> [Double] {
        
        let groupByName = Dictionary(grouping: operations) { (operation) -> String in
            return operation.groupName
        }
        
        var sumArray = [Double]()
        
        for operation in groupByName {
            sumArray.append(operation.value.reduce(0) { partialResult, y in
                partialResult + y.amount
            })
        }
        
        return sumArray
    }
}

struct HistoryViewComponent: View {
    
    @ObservedObject var viewModel: HistoryViewComponent.ViewModel
    
    var body: some View {
        
        VStack {
            
            HStack(alignment: .center) {
                
                Text(viewModel.title)
                    .font(Font.system(size: 22, weight: .bold))
                
                Spacer()
                
                Button {
                    
                } label: {
                    
                    Image.ic16Sliders
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                    
                }
                .background(Color.mainColorsGrayLightest)
                .cornerRadius(90)
                
            }
            .padding(.bottom, 15)
            
            if let spending = viewModel.spendingViewModel {
                
                SegmentedBarView(viewModel: spending)
                    .frame(height: 44)
                    .padding(.bottom, 32)
            }
            
            switch viewModel.listState {
            case .empty(let emptyViewModel):
                EmptyOperationsView(viewModel: emptyViewModel)
                
            case .list(let operationsViewModel):
                
                ForEach(viewModel.dateOperations) { operation in
                    
                    VStack(alignment: .leading, spacing: 0){
                        
                        Text(operation.date)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .padding(.bottom, 16)
                        
                        ForEach(operation.operations) { item in
                            
                            HStack(alignment: .top, spacing: 20) {
                                
                                if let image = item.image {
                                    
                                    image
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                } else {
                                    
                                    Circle()
                                        .frame(width: 40, height: 40)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    Text(item.title)
                                        .font(.system(size: 16))
                                        .fontWeight(.regular)
                                        .lineLimit(1)
                                    
                                    Text(item.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(.mainColorsGray)
                                        .fontWeight(.light)
                                }
                                
                                Spacer()
                                
                                Text(item.amount)
                                
                            }
                            .padding(.vertical, 8)
                            .onTapGesture {
                                item
                            }
                        }
                    }
                }
                .padding(.bottom, 32)
                
            case .error(let errorViewModel):
                ErrorRequestView(viewModel: errorViewModel)
                
            case .loading:
                LoadingPlaceholder()
            }
        }
        .padding(.horizontal, 20)
    }
    
    struct LoadingPlaceholder: View {
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 20){
                
                ForEach(0..<3) { _ in
                    
                    Color.mainColorsGrayMedium
                        .frame(width: 189, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .shimmering(active: true, bounce: true)
                        .frame(alignment: .leading)
                    
                    HStack(spacing: 20) {
                        
                        Color.mainColorsGrayMedium
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 90))
                            .shimmering(active: true, bounce: true)
                        
                        VStack(spacing: 8) {
                            
                            Color.mainColorsGrayMedium
                                .frame(width: 189, height: 20)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                                .shimmering(active: true, bounce: true)
                            
                            Color.mainColorsGrayMedium
                                .frame(width: 189, height: 12)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                                .shimmering(active: true, bounce: true)
                        }
                        
                        Color.mainColorsGrayMedium
                            .frame(height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                            .shimmering(active: true, bounce: true)
                            .frame(alignment: .top)
                    }
                }
            }
        }
    }
    
    struct EmptyOperationsView: View {
        
        var viewModel: ViewModel.OperationsEmptyViewModel
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                viewModel.image
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 64, height: 64)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(90)
                
                Text(viewModel.title)
                    .font(Font.system(size: 14, weight: .light))
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
    
    struct ErrorRequestView: View {
        
        var viewModel: ViewModel.OperationsErrorViewModel
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                viewModel.image
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 64, height: 64)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(90)
                VStack(spacing: 13) {
                    Text(viewModel.errorTitle)
                        .font(Font.system(size: 20, weight: .semibold))
                        .foregroundColor(.mainColorsBlackMedium)
                    
                    Text(viewModel.subTitle)
                        .font(Font.system(size: 16, weight: .light))
                        .foregroundColor(.gray)
                }
                Button {
                    viewModel.button.action(ModelAction.Statement.List.Request.init(productId: 10000122929, productType: .card))
                } label: {
                    Text(viewModel.button.title)
                        .foregroundColor(.mainColorsBlackMedium)
                }
            }
        }
    }
}

struct HistoryViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            HistoryViewComponent(viewModel: .init(dateOperations: [.init(date: "25 августа, ср", operations: [.init(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit), .init(title: "Selhozmarket", image: Image.init("GKH", bundle: nil), subtitle: "Магазин", amount: "-230 Р", type: .credit)]), .init(date: "26 августа, ср", operations: [.init(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)])], spendingViewModel: .spending, productId: 1, model: .emptyMock))
                .previewLayout(.fixed(width: 360, height: 500))
            
            HistoryViewComponent(viewModel: .init(dateOperations: [.init(date: "25 августа, ср", operations: [.init(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit)]), .init(date: "26 августа, ср", operations: [.init(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)])], spendingViewModel: nil, productId: 1, model: .emptyMock))
                .previewLayout(.fixed(width: 400, height: 400))
            
            HistoryViewComponent(viewModel: .init(dateOperations: [], spendingViewModel: nil, productId: 1, model: .emptyMock))
                .previewLayout(.fixed(width: 400, height: 400))
            
        }
    }
}

extension HistoryViewComponent.ViewModel.OperationsDateViewModel {
    
    static let debitOperation = Operation(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .credit)
    
    static let creditOperation = Operation(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)
    
}

extension HistoryViewComponent.ViewModel {
    
    static let sampleHistory = HistoryViewComponent.ViewModel( dateOperations: [.init(date: "12 декабря", operations: [.init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)])], spendingViewModel: .init(value: [100, 300]), productId: 1, model: .emptyMock)
}
