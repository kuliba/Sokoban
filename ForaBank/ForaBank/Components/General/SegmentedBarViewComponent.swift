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
        
        @Published var value: [Double]
        @Published var colors = [Color.bGIconRedLight, Color.bGIconPurpleLight, Color.bGIconPinkLight, Color.bGIconPinkLightest, Color.bGIconDeepPurpleMedium, Color.bGIconDeepPurpleLight, Color.bGIconDeepPurpleLightest, Color.bGIconIndigoLight, Color.bGIconIndigoLightest, Color.bGIconBlueLight, Color.bGIconBlueLightest, Color.bGIconTealLight, Color.bGIconGreenLight, Color.bGIconGreenLightest, Color.bGIconLimeLight, Color.bGIconDeepOrangeLight, Color.bGIconOrangeLight, Color.bGIconOrangeLightest, Color.bGIconAmberLight, Color.bGIconYellowLight, Color.bGIconDeepIndigoLight, Color.bGIconDeepBlueLight, Color.bGIconCyanLight, Color.bGIconDeepLimeLight]
        @Published var totalValue: Double
        
        internal init(value: [Double]) {
            
            self.totalValue = value.reduce(0, +)
            self.value = value
        }
    }
}

//MARK: - View

struct SegmentedBarView: View {
    
    var viewModel: SegmentedBarView.ViewModel
    
    var body: some View {
        
        
        GeometryReader { geometry in
            
            ZStack {
                
                HStack(alignment: .center, spacing: 0) {
                    
                    ForEach(viewModel.value.indices) { i in
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(viewModel.value[i] / viewModel.totalValue), height: 44)
                            .foregroundColor(viewModel.colors[i])
                            .animation(.easeInOut)
                    }
                }
                
                HStack(alignment: .center) {
                    
                    Text("Траты за август")
                    
                    Spacer()
                    
                    Text(viewModel.totalValue.currencyFormatter())
                }
                .padding(.horizontal, 16)
            }
            .cornerRadius(8)
        }
    }
}

//MARK: - Preview

struct SegmentedBarView_Previews: PreviewProvider {
    static var previews: some View {
        
        SegmentedBarView(viewModel: .spending)
            .previewLayout(.fixed(width: 335, height: 100))
    }
}

//MARK: - Preview Content

extension SegmentedBarView.ViewModel {
    
    static let spending = SegmentedBarView.ViewModel(value: [100, 400, 50, 200, 500, 100, 300, 10, 100, 300])
}
