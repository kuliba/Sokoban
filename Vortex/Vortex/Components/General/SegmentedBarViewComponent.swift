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
        let titleLabel: String
        let totalValue: Double
        let totalValueFormatted: String
        let currencyCode: String
        
        private let model: Model
        
        var sortedValues: [(key: ProductStatementMerchantGroup, Double)] {
            
            values.sorted(by: { $0.value > $1.value })
        }
        
        init(
            values: [ProductStatementMerchantGroup: Double],
            titleLabel: String,
            currencyCode: String,
            prefixTotalValue: String = "",
            model: Model = .emptyMock
        ) {
            
            self.values = values
            self.model = model
            self.currencyCode = currencyCode
            self.titleLabel = titleLabel
            
            self.totalValue = values.values.reduce(0, +)
           
            self.totalValueFormatted = (totalValue != 0 ? prefixTotalValue : "")
                                     + (model.amountFormatted(amount: totalValue,
                                            currencyCode: currencyCode,
                                            style: totalValue != 0 ? .normal : .clipped) ?? String(totalValue))
        }
        
        convenience init(
            mappedValues: [ProductStatementMerchantGroup: Double],
            productType: ProductType,
            currencyCode: String,
            selectRange: ClosedRange<Date>?,
            model: Model
        ) {
            
            self.init(
                values: mappedValues,
                titleLabel: Self.getTitleLabel(
                    productType: productType,
                    selectRange: selectRange
                ),
                currencyCode: currencyCode,
                prefixTotalValue: Self.getPrefixTotalValue(productType: productType),
                model: model
            )
        }
        
        // это согласованный костыль
        convenience init(
            stringValues: [String: Double],
            productType: ProductType,
            currencyCode: String,
            selectRange: ClosedRange<Date>?,
            model: Model
        ) {
            
            var mockValues = [ProductStatementMerchantGroup: Double]()
            let merchantGroup = ProductStatementMerchantGroup.allCases
            var i = 0
            var sumEndGroup = 0.0
            
            stringValues.sorted(by: {$0.value > $1.value})
                .forEach { key, value in
                    
                    if i < merchantGroup.count - 1 {
                        mockValues[merchantGroup[i]] = value
                    } else {
                        sumEndGroup += value
                        mockValues[merchantGroup[merchantGroup.count - 1]] = sumEndGroup
                    }
                    
                    i += 1
                }
            
            self.init(
                values: mockValues,
                titleLabel: Self.getTitleLabel(
                    productType: productType,
                    selectRange: selectRange
                ),
                currencyCode: currencyCode,
                prefixTotalValue: Self.getPrefixTotalValue(productType: productType),
                model: model
            )
        }
        
        private static func getTitleLabel(
            productType: ProductType,
            selectRange: ClosedRange<Date>?
        ) -> String {
            
            if let selectRange {
                
                let dateFormatted = ("\(DateFormatter.shortDateGTM0.string(from: selectRange.lowerBound)) - \(DateFormatter.shortDateGTM0.string(from: selectRange.upperBound))")
                
                return productType == .deposit ? "Мой доход за \(dateFormatted)" : "Tраты за \(dateFormatted)"
                
            } else {
                
                let dateFormatter = DateFormatter.monthFormatter
                let currentMonth = dateFormatter.string(from: Date())
                
                return productType == .deposit ? "Мой доход за \(currentMonth)" : "Tраты за \(currentMonth)"
            }
        }
        
        private static func getPrefixTotalValue(productType: ProductType) -> String {
            
            return productType == .deposit ? "+ " : "- "
        }
        
    }
}

//MARK: - View

private extension SegmentedBarView {

    @ViewBuilder
    func bar(width: CGFloat) -> some View {
        
        if viewModel.totalValue != 0 {
                
            bar(coef: width / viewModel.totalValue)
        
        } else {
            
            RoundedRectangle(cornerRadius: 8)
                .frame(width: width)
                .foregroundColor(.mainColorsGrayLightest)
        }
    }
    
    @ViewBuilder
    func bar(coef: CGFloat) -> some View {
        
        HStack(alignment: .center, spacing: 0) {
    
            ForEach(viewModel.sortedValues, id: \.key) { key, value in
                
                key.color
                    .frame(width: value * coef)
                    .animation(.easeInOut, value: value)
            }
        }
        .cornerRadius(8)
    }
}

struct SegmentedBarView: View {
    
    let viewModel: SegmentedBarView.ViewModel
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Text(viewModel.titleLabel)
                    .accessibilityIdentifier("spendingTitleMonth")
                Spacer()
                Text(viewModel.totalValueFormatted)
                    .accessibilityIdentifier("spendingAmount")
            }
            .foregroundColor(.textSecondary)
            .font(.textH4M16240())
            .padding(.bottom, 6)
            
            GeometryReader { geometry in
                
                bar(width: geometry.size.width)
            }
            .frame(height: 8)
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
                                                     titleLabel: "Траты за август",
                                                     currencyCode: "RUB",
                                                     prefixTotalValue: "- ")
    
    static let zero = SegmentedBarView.ViewModel(values: [:],
                                                 titleLabel: "Траты за август",
                                                 currencyCode: "USD")
}
