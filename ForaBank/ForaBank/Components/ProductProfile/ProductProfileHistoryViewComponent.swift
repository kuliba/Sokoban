//
//  HistoryViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI
import Combine
import Shimmer

//MARK: - ViewModel

extension ProductProfileHistoryView {
    
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
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ModelAction.Statement.List.Response:
                        switch payload.result {
                        case .failure(message: _):
                            self.listState = .error(.init(button: .init(action: {_ in
                                self.model.action.send(ModelAction.Statement.List.Request(productId: self.productId, productType: .card))
                                self.listState = .loading
                            })))
                            
                        case .success(statement: let statement):
                            
                            self.listState = .list(separationDate(operations: statement))
                            self.dateOperations = separationDate(operations: statement)
                            if sumDeifferentGroup(operations: statement).count > 0 {
                                
                                self.spendingViewModel = .init(value: sumDeifferentGroup(operations: statement))
                            }
                        }
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
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
            let image = Image.ic24Clock
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
            let action: () -> Void
            
            internal init(date: String, operations: [Operation], action: @escaping () -> Void) {
                
                self.date = date
                self.operations = operations
                self.action = action
            }
            
            struct Operation: Identifiable {
                
                let id: String
                let title: String
                let image: Image?
                let subtitle: String
                let amount: String
                let type: OperationType
                
                internal init(id: String, title: String, image: Image?, subtitle: String, amount: String, type: OperationType) {
                    
                    self.id = id
                    self.title = title
                    self.image = image
                    self.subtitle = subtitle
                    self.amount = amount
                    self.type = type
                }
                
                init(productStatementData: ProductStatementData) {
                    
                    if let operationId = productStatementData.operationId {
                        
                        self.id = operationId
                    } else {
                        self.id = ""
                    }
                    
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

enum HistoryViewModelAction {
    
    enum DetailTapped {
        
        struct Detail: Action {
            
            let statement: String
        }
    }
}

extension ProductProfileHistoryView.ViewModel {
    
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
            
            dateOperations.append(OperationsDateViewModel(date: date.key, operations: operations, action: {}))
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

//MARK: - View

struct ProductProfileHistoryView: View {
    
    @ObservedObject var viewModel: ProductProfileHistoryView.ViewModel
    
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
                    .padding(.top, 20)
                
            case .list(_):
                
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
                                        .background(Color.mainColorsGrayLightest)
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
                            
                                self.viewModel.action.send(HistoryViewModelAction.DetailTapped.Detail(statement: item.id))
                            }
                        }
                    }
                }
                .padding(.bottom, 32)
                
            case .error(let errorViewModel):
                ErrorRequestView(viewModel: errorViewModel)
                    .padding(.top, 20)
                
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
                    .foregroundColor(.mainColorsBlack)
                    .frame(width: 76, height: 76)
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
                    
                } label: {
                    Text(viewModel.button.title)
                        .foregroundColor(.mainColorsBlackMedium)
                        .frame(width: 300, height: 48, alignment: .center)
                        .padding(.horizontal, 20)
                }
                .background(Color.buttonSecondary)
                .cornerRadius(8)
                
            }
        }
    }
}

//MARK: - Preview

struct HistoryViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductProfileHistoryView(viewModel: .init(dateOperations: [.init(date: "25 августа, ср", operations: [.init(id: "", title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit), .init(id: "", title: "Selhozmarket", image: Image.init("GKH", bundle: nil), subtitle: "Магазин", amount: "-230 Р", type: .credit)], action: {}), .init(date: "26 августа, ср", operations: [.init(id: "", title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)], action: {})], spendingViewModel: .spending, productId: 1, model: .emptyMock))
                .previewLayout(.fixed(width: 360, height: 500))
            
            ProductProfileHistoryView(viewModel: .init(dateOperations: [.init(date: "25 августа, ср", operations: [.init(id: "", title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit)], action: {}), .init(date: "26 августа, ср", operations: [.init(id: "", title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)], action: {})], spendingViewModel: nil, productId: 1, model: .emptyMock))
                .previewLayout(.fixed(width: 400, height: 400))
            
            ProductProfileHistoryView(viewModel: .init(dateOperations: [], spendingViewModel: nil, productId: 1, model: .emptyMock))
                .previewLayout(.fixed(width: 400, height: 400))
            
        }
    }
}

//MARK: - Preview Content

extension ProductProfileHistoryView.ViewModel.OperationsDateViewModel {
    
    static let debitOperation = Operation(id: "", title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .credit)
    
    static let creditOperation = Operation(id: "", title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)
    
}

extension ProductProfileHistoryView.ViewModel {
    
    static let sampleHistory = ProductProfileHistoryView.ViewModel( dateOperations: [.init(date: "12 декабря", operations: [.init(id: "", title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(id: "", title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(id: "", title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(id: "", title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(id: "", title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)], action: {})], spendingViewModel: .init(value: [100, 300]), productId: 1, model: .emptyMock)
}
