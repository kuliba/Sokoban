//
//  SpendingViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI

extension SegmentedBar {
    
    class ViewModel: ObservableObject {
        
        @Published var value: [Double]
        @Published var colors: [Color]
        
        internal init(value: [Double], colors: [Color]) {
            
            self.value = value
            self.colors = colors
        }
    }
}

struct SegmentedBar: View {
    
    var viewModel: SegmentedBar.ViewModel
    
    private var totalValue: Double {
        get {
            return viewModel.value.reduce(0) { (res, val) -> Double in
                return res + val
            }
        }
    }
    
    var body: some View {
        
        
        GeometryReader { geometry in
            
            ZStack {
                
                HStack(alignment: .center, spacing: 0) {
                    
                    ForEach(viewModel.value.indices) { i in
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(viewModel.value[i] / self.totalValue), height: 44)
                            .foregroundColor(viewModel.colors[i])
                            .animation(.easeInOut)
                    }
                }
                
                HStack(alignment: .center) {
                    
                    Text("Траты за август")
                    
                    Spacer()
                    
                    Text("\(totalValue)")
                }
                .padding(.horizontal, 16)
            }
            .cornerRadius(8)
        }
    }
}

struct SegmentedBarTest_Previews: PreviewProvider {
    static var previews: some View {
        
        SegmentedBar(viewModel: .spending)
            .previewLayout(.fixed(width: 335, height: 100))
    }
}

extension SegmentedBar.ViewModel {
    
    static let spending = SegmentedBar.ViewModel(value: [100, 400, 50, 200], colors: [Color.bGIconDeepIndigoLight, Color.bGIconDeepLimeLight, Color.bGIconBlueLight, Color.bGIconDeepOrangeLight])
}
