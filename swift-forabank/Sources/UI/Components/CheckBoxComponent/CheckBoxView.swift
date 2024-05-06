//
//  CheckBoxView.swift
//
//
//  Created by Дмитрий Савушкин on 01.03.2024.
//

import SwiftUI
import SharedConfigs

public struct CheckBoxView: View {
    
    private let isChecked: Bool
    private let checkBoxEvent: (CheckBoxEvent) -> Void
    private let config: Config
    
    public init(
        isChecked: Bool,
        checkBoxEvent: @escaping (CheckBoxEvent) -> Void,
        config: Config
    ) {
        self.isChecked = isChecked
        self.checkBoxEvent = checkBoxEvent
        self.config = config
    }
    
    public var body: some View {
        
        HStack(spacing: 16) {
            
            ZStack {
                
                CheckView(
                    isChecked: isChecked,
                    config: config
                )
            }
            .animation(nil, value: isChecked)
            .frame(width: 24, height: 24)
            
            config.title.text(withConfig: config.titleConfig)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            
            checkBoxEvent(.buttonTapped)
            
        }
    }
}

extension CheckBoxView {
    
    public struct CheckView: View {
        
        private let isChecked: Bool
        private let config: Config
        
        init(isChecked: Bool, config: Config) {
            
            self.isChecked = isChecked
            self.config = config
        }
        
        public var body: some View {
            
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

public extension CheckBoxView {
    
    struct Config {
        
        let title: String
        let titleConfig: TextConfig
        
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
        
        public init(
            title: String,
            titleConfig: TextConfig,
            lineWidth: CGFloat,
            strokeColor: Color,
            dashPhase: CGFloat
        ) {
            self.title = title
            self.titleConfig = titleConfig
            self.lineWidth = lineWidth
            self.strokeColor = strokeColor
            self.dashPhase = dashPhase
        }
    }
}

public extension CheckBoxView.Config {
    
    static let preview: Self = .init(
        title: "Оплата ЖКХ",
        titleConfig: .init(textFont: .body, textColor: .black),
        lineWidth: 2,
        strokeColor: .green,
        dashPhase: 70
    )
}
// MARK: - Preview

struct CheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CheckBoxView(
            isChecked: true,
            checkBoxEvent: { _ in },
            config: .preview
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
