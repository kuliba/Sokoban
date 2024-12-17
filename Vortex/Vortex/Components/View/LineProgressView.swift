//
//  LineProgressView.swift
//  ForaBank
//
//  Created by Max Gribov on 16.06.2022.
//

import SwiftUI

struct LineProgressView: View {
    
    @Binding var progress: CGFloat
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack() {
                
                Capsule()
                    .stroke(Color.textPrimary, lineWidth: 1)
                    .frame(height: 6)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: (geometry.size.width - 44) / 39) {
                    
                    ForEach(0..<40) { _ in
                        
                        Capsule()
                            .frame(width: 1, height: 2)
                            .foregroundColor(.textPrimary)
                    }
                }
                
                Capsule()
                    .fill(LinearGradient(
                        gradient: .init(colors: [Color(hex: "22C183"), Color(hex: "FFBB36") ,Color(hex: "FF3636")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .padding(2)
                    .clipShape(ClipArea(width: geometry.size.width * min(max(progress, 0), 1)))

            }.frame(height: 6)
        }
    }
}

fileprivate struct ClipArea: Shape {
    
    let width: CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: width, y: rect.minY))
        path.addLine(to: CGPoint(x: width, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

struct LineProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            LineProgressView(progress: .constant(0))
                .background(Color.black)
            .previewLayout(.fixed(width: 375, height: 20))
            
            LineProgressView(progress: .constant(0.5))
                .background(Color.black)
            .previewLayout(.fixed(width: 375, height: 20))
            
            LineProgressView(progress: .constant(1.0))
                .background(Color.black)
            .previewLayout(.fixed(width: 375, height: 20))
        }
    }
}


