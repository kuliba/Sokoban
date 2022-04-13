//
//  HistoryViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI
import Combine

extension HistoryViewComponent {
    
    class ViewModel: ObservableObject {
        
        let title = "История операций"
        var dateOperations: [DateOperations]
        var spending: SegmentedBar.ViewModel?
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init( dateOperations: [HistoryViewComponent.ViewModel.DateOperations], spending: SegmentedBar.ViewModel?, model: Model = .emptyMock) {
            
            self.dateOperations = dateOperations
            self.spending = spending
            self.model = model
        }
        
        init(_ model: Model = .emptyMock) {
            
            self.dateOperations = []
            self.spending = nil
            self.model = model
            
            bind()
        }
        
        private func bind() {
            
            model.statement
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] operations in
                    
                    let groupByDate = Dictionary(grouping: operations) { (operation) -> String in
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat =  "d MMMM, E"
                        dateFormatter.timeZone = .current
                        dateFormatter.locale = Locale(identifier: "ru_RU")
                        let localDate = dateFormatter.string(from: operation.tranDate)
                        
                        return localDate
                    }
                    
                    let sortedArray = groupByDate.sorted(by: { $0.0 > $1.0 })
                    
                    func sumDeifferentGroup() -> [Double] {
                        
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
                    
                    self.spending = .init(value: sumDeifferentGroup())
                    
                    for date in sortedArray {
                        
                        var operations = [DateOperations.Operation]()
                        
                        for operation in date.value {
                            
                            operations.append(HistoryViewComponent.ViewModel.DateOperations.Operation(productStatementData: operation))
                        }
                        
                        self.dateOperations.append(HistoryViewComponent.ViewModel.DateOperations(date: date.key, operations: operations))
                        
                    }
                    
                }.store(in: &bindings)
        }
        
        struct DateOperations: Identifiable {
            
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
                
                internal init(title: String, image: Image, subtitle: String, amount: String, type: OperationType) {
                    
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
                    self.amount = productStatementData.amount.currencyFormatter()
                    
                    self.type = productStatementData.operationType
                }
            }
        }
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
            
            if let spending = viewModel.spending {
                
                SegmentedBar(viewModel: spending)
                    .frame(height: 44)
                    .padding(.bottom, 32)
            }
            
            if !viewModel.dateOperations.isEmpty {
                
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
                                    
                                    
                                    Text(item.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundColor(.mainColorsGray)
                                        .fontWeight(.light)
                                }
                                
                                Spacer()
                                
                                Text(item.amount)
                                
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.bottom, 32)
                
            } else {
                
                Spacer()
                
                EmptyOperationsView()
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
    
    struct EmptyOperationsView: View {
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                Image.ic24Search
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 64, height: 64)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(90)
                
                Text("Нет операций")
                    .font(Font.system(size: 14, weight: .light))
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
    
    struct ErrorRequestView: View {
        
        var body: some View {
            
            VStack(spacing: 24) {
                
                Image.ic24Search
                    .foregroundColor(.mainColorsGray)
                    .frame(width: 64, height: 64)
                    .background(Color.mainColorsGrayLightest)
                    .cornerRadius(90)
                
                Text("Нет операций")
                    .font(Font.system(size: 14, weight: .light))
                    .foregroundColor(.mainColorsGray)
                
                Button {
                    
                } label: {
                    Text("Повторить запрос")
                }
                
            }
        }
    }
}

struct HistoryViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            HistoryViewComponent(viewModel: .init(dateOperations: [.init(date: "25 августа, ср", operations: [.init(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit), .init(title: "Selhozmarket", image: Image.init("GKH", bundle: nil), subtitle: "Магазин", amount: "-230 Р", type: .credit)]), .init(date: "26 августа, ср", operations: [.init(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)])], spending: .spending))
                .previewLayout(.fixed(width: 360, height: 500))
            
            HistoryViewComponent(viewModel: .init(dateOperations: [.init(date: "25 августа, ср", operations: [.init(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit)]), .init(date: "26 августа, ср", operations: [.init(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)])], spending: nil))
                .previewLayout(.fixed(width: 400, height: 400))
            
            HistoryViewComponent(viewModel: .init(dateOperations: [], spending: nil))
                .previewLayout(.fixed(width: 400, height: 400))
            
        }
    }
}

extension HistoryViewComponent.ViewModel.DateOperations {
    
    static let debitOperation = Operation(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .credit)
    
    static let creditOperation = Operation(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)
    
}

extension HistoryViewComponent.ViewModel {
    
    static let sampleHistory = HistoryViewComponent.ViewModel( dateOperations: [.init(date: "12 декабря", operations: [.init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit), .init(title: "Оплата банка", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)])], spending: .init(value: [100, 300]))
}
