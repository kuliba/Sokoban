//
//  HistoryViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI

extension HistoryViewComponent {
    
    class ViewModel: ObservableObject {
        
        let title: String
        let dateOperations: [DateOperations]
        let spending: SegmentedBar.ViewModel?
        
        internal init(title: String, dateOperations: [HistoryViewComponent.ViewModel.DateOperations], spending: SegmentedBar.ViewModel?) {
            
            self.title = title
            self.dateOperations = dateOperations
            self.spending = spending
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
                    let image: Image
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
                    
                    enum OperationType {
                        
                        case debit
                        case credit
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
            
            ForEach(viewModel.dateOperations) { operation in

                VStack(alignment: .leading, spacing: 0){
                    
                    Text(operation.date)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .padding(.bottom, 16)
                    
                    ForEach(operation.operations) { item in
                        
                        HStack(alignment: .top, spacing: 20) {
                            
                            item.image
                                .resizable()
                                .frame(width: 40, height: 40)
                            
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
        }
        .padding(.horizontal, 20)
    }
}

struct HistoryViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
         
            HistoryViewComponent(viewModel: .init(title: "История операций", dateOperations: [.init(date: "25 августа, ср", operations: [.init(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit), .init(title: "Selhozmarket", image: Image.init("GKH", bundle: nil), subtitle: "Магазин", amount: "-230 Р", type: .credit)]), .init(date: "26 августа, ср", operations: [.init(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)])], spending: .spending))
            
            HistoryViewComponent(viewModel: .init(title: "История операци", dateOperations: [.init(date: "25 августа, ср", operations: [.init(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .debit)]), .init(date: "26 августа, ср", operations: [.init(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .debit)])], spending: nil))
        }
    }
}

extension HistoryViewComponent.ViewModel.DateOperations {
    
    static let debitOperation = Operation(title: "Плата за обслуживание", image: Image("MigAvatar", bundle: nil), subtitle: "Услуги банка", amount: "-65 Р", type: .credit)
    
    static let creditOperation = Operation(title: "Оплата банка", image: Image.init("foraContactImage", bundle: nil), subtitle: "Услуги банка", amount: "-100 Р", type: .credit)
    
}
