//
//  CircleSegmentedBarView.swift
//  ForaBank
//
//  Created by Дмитрий on 22.03.2022.
//

import SwiftUI
import CoreData
import Combine

struct CircleSegmentedBarView: View {
    
    var values: [Double]
    var totalDebt: Double?
    @State var colors: [Color]
    
    private var totalValue: Double {
        get {
            if let totalDebt = totalDebt {
                return totalDebt
            } else {
                return values.reduce(0) { (res, val) -> Double in
                    return res + val
            }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                ForEach(self.values.indices) { i in
                    
                    Circle()
                        .trim(from: i == 0 ? 0.0 : (CGFloat(self.values[i-1] / self.totalValue)+0.03), to: i == 0 ? CGFloat(self.values[i] / self.totalValue) : 0.97)
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [], dashPhase: 0))
                        .frame(width: 96, height: 96, alignment: .center)
                        .foregroundColor(self.colors[i])
                        .rotationEffect(.degrees(-90.0))
                }
            }
        }
    }
}

struct DetailAccountSegmentedBarTest: View {
    
    @State var values: [Double] = [300000, 98454.54]
    var colors: [Color] = [.red, .white]
    
    var totalValue: Double {
        get {
            values.reduce(0) { (res, val) -> Double in
                return res + val
            }
        }
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 10) {
            
            VStack(alignment: .center, spacing: 12) {

                CircleSegmentedBarView(values: values, colors: colors)
                    .frame(width: nil, height: 6, alignment: .center)
            }
            .padding(18)
            .shadow(color: Color.gray.opacity(0.5), radius: 50, x: 0, y: 2)
            
            Spacer()
        }
        
    }
}

struct DetailAccountSegmentedBarTest_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DetailAccountSegmentedBarTest()
            .previewLayout(.fixed(width: 200, height: 200))
    }
}

