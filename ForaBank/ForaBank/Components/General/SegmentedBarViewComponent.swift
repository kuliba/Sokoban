//
//  SpendingViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI

//MARK: - ViewModel

extension SegmentedBarView {
    
    class ViewModel {
        
        let values: [ProductStatementMerchantGroup: Double]
        let label: String
        let totalValue: Double
        let totalValueFormatted: String
        let currencyCode: String
        
        private let model: Model
        
        private static var currentMonth: String {
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            return dateFormatter.string(from: now)
        }
        
        init(values: [ProductStatementMerchantGroup: Double],
             label: String,
             currencyCode: String,
             model: Model = .emptyMock) {
            
            self.model = model
            self.currencyCode = currencyCode
            
            self.totalValue = values.values.reduce(0, +)
            self.totalValueFormatted = model.amountFormatted(amount: totalValue,
                                            currencyCode: currencyCode,
                                            style: totalValue != 0 ? .normal : .clipped) ?? String(totalValue)
            self.values = values
            self.label = label
        }
        
        convenience init(mappedValues: [ProductStatementMerchantGroup: Double],
                         productType: ProductType,
                         currencyCode: String,
                         model: Model) {
            
            self.init(values: mappedValues,
                      label: productType == .deposit
                        ? "Мой доход за \(Self.currentMonth)"
                        : "Tраты за \(Self.currentMonth)",
                      currencyCode: currencyCode,
                      model: model)
                
        }
    }
}

//MARK: - View

struct SegmentedBarView: View {
    
    let viewModel: SegmentedBarView.ViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                HStack {
                
                    Text(viewModel.label)
                    Spacer()
                    Text(viewModel.totalValueFormatted)
                }
                .foregroundColor(.textSecondary)
                .font(.textH4M16240())
                .padding(.bottom, 6)
            
                if viewModel.totalValue != 0 {
                    ZStack {
                
                        HStack(alignment: .center, spacing: 0) {
                    
                            ForEach(viewModel
                                .values.sorted(by: {$0.value > $1.value}), id: \.key) { key, value in
                        
                                    Rectangle()
                                        .frame(width: geometry.size.width
                                            * CGFloat(value / viewModel.totalValue),height: 8)
                                        .foregroundColor(key.color)
                                        .animation(.easeInOut)
                            }
                        }
                    }.cornerRadius(8)
                
                } else {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: geometry.size.width, height: 8)
                        .foregroundColor(.mainColorsGrayLightest)
                }
            }
        }
    }
}

//MARK: - Preview

struct SegmentedBarView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            SegmentedBarView(viewModel: .spending)
                .previewLayout(.fixed(width: 335, height: 100))
            
            SegmentedBarView(viewModel: .zero)
                .previewLayout(.fixed(width: 335, height: 100))
            
        }
    }
}

//MARK: - Preview Content

extension SegmentedBarView.ViewModel {
    
    static let spending = SegmentedBarView.ViewModel(values: [.services: 1000.24,
                                                             .internalOperations: 300.35,
                                                             .stateServices: 500.0,
                                                             .transport: 100.00],
                                                     label: "Траты за август",
                                                     currencyCode: "RUB")
    
    static let zero = SegmentedBarView.ViewModel(values: [:],
                                                 label: "Траты за август",
                                                 currencyCode: "USD")
}
