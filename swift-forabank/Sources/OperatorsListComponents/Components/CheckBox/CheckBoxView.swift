//
//  CheckBoxView.swift
//
//
//  Created by Дмитрий Савушкин on 01.03.2024.
//

import SwiftUI

struct CheckBoxView: View {
    
    let isChecked: Bool
    let checkBoxEvent: (CheckBoxEvent) -> Void
    let config: CheckBoxViewConfig
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            ZStack {
                
                CheckView(
                    isChecked: isChecked,
                    config: config
                )
            }
            .animation(nil, value: isChecked)
            .frame(width: 24, height: 24)
            
            Text(config.title)
                .foregroundColor(config.titleForeground)
                .font(config.titleFont)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            
            checkBoxEvent(.buttonTapped)
            
        }
    }
}

extension CheckBoxView {
    
    struct CheckView: View {
        
        let isChecked: Bool
        let config: CheckBoxViewConfig
        
        var body: some View {
            
            if isChecked {
                
                GeometryReader { proxy in
                    
                    Path { path in
                        
                        let frame = proxy.frame(in: .global)
                        let center = frame.height / 2
                        
                        let centerPoint: CGPoint = .init(x: center, y: center)
                        let point: CGPoint = .init(x: center - 3, y: center - 3)
                        let endPoint: CGPoint = .init(x: frame.width, y: 0)
                        
                        path.move(to: point)
                        path.addLine(to: centerPoint)
                        path.addLine(to: endPoint)
                    }
                    .stroke(lineWidth: config.lineWidth)
                    .foregroundColor(config.strokeColor)
                }
                .offset(x: 0, y: 1.5)
                .frame(width: 20, height: 20)
                
            } else {
             
                RoundedRectangle(cornerRadius: 3)
                    .trim(from: 0, to: 1)
                    .stroke(style: config.strokeStyle)
                    .foregroundColor(config.strokeColor)
                    .frame(width: 18, height: 18)
                
            }
        }
    }
}

extension CheckBoxView {
    
    struct CheckBoxViewConfig {
        
        let title: String
        let titleFont: Font
        let titleForeground: Color
        
        let lineWidth: CGFloat
        let strokeColor: Color
        let dashPhase: CGFloat
        
        var strokeStyle: StrokeStyle {
            
            .init(
                lineWidth: lineWidth,
                lineCap: .round,
                dash: [123],
                dashPhase: dashPhase
            )
        }
    }
}

// MARK: - Preview

struct CheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CheckBoxView(
            isChecked: true,
            checkBoxEvent: { _ in },
            config: .init(
                title: "Оплата ЖКХ",
                titleFont: .body,
                titleForeground: .black,
                lineWidth: 2,
                strokeColor: .green,
                dashPhase: 70
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
