//
//  SpendingViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI

//MARK: - ViewModel

extension SegmentedBarView {
    
    class ViewModel: ObservableObject {
        
        @Published var value: [ProductStatementGroup: Double]
        @Published var label: String
        @Published var totalValue: Double
        
        init(value: [ProductStatementGroup: Double], label: String) {
            
            self.totalValue = value.values.reduce(0, +)
            self.value = value
            self.label = label
        }
    }
}

//MARK: - View

struct SegmentedBarView: View {
    
    var viewModel: SegmentedBarView.ViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                HStack {
                
                    Text(viewModel.label)
                    Spacer()
                    Text(viewModel.totalValue.currencyFormatter())
                }
                .foregroundColor(.textSecondary)
                .font(.textH4M16240())
                .padding(.bottom, 6)
            
                if viewModel.totalValue != 0 {
                    ZStack {
                
                        HStack(alignment: .center, spacing: 0) {
                    
                            ForEach(viewModel
                                .value.sorted(by: {$0.value > $1.value}), id: \.key) { key, value in
                        
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
    
    static let spending = SegmentedBarView.ViewModel(value: [.services: 1000.24,
                                                             .internalOperations: 300.35,
                                                             .stateServices: 500.0,
                                                             .transport: 100.00],
                                                     label: "Траты за август")
    
    static let zero = SegmentedBarView.ViewModel(value: [:],
                                                     label: "Траты за август")
}
