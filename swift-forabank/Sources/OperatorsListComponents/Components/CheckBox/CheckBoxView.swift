//
//  CheckBoxView.swift
//
//
//  Created by Дмитрий Савушкин on 01.03.2024.
//

import SwiftUI

struct CheckBoxView: View {
    
    let viewModel: CheckBoxViewModel
    let config: CheckBoxViewConfig
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 3)
                    .trim(from: 0, to: 1)
                    .stroke(style: config.strokeStyle)
                    .foregroundColor(config.strokeColor)
                    .frame(width: 18, height: 18)
                
                if viewModel.state == .checked {
                    
                    CheckView(
                        viewModel: viewModel,
                        config: config
                    )
                }
            }
            .animation(nil, value: viewModel.state == .checked)
            .frame(width: 24, height: 24)
            
            Text(viewModel.title)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            
            viewModel.tapAction()
            
        }
    }
}

extension CheckBoxView {
    
    struct CheckView: View {
        
        let viewModel: CheckBoxViewModel
        let config: CheckBoxViewConfig
        
        var body: some View {
            
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
        }
    }
}

extension CheckBoxView {
    
    struct CheckBoxViewConfig {
        
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
            viewModel: .init(
                state: .checked,
                title: "Оплата ЖКХ",
                tapAction: {}
            ),
            config: .init(
                lineWidth: 2,
                strokeColor: .green,
                dashPhase: 70
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
