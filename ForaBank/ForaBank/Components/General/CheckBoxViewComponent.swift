//
//  CheckBoxViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 07.12.2022.
//

import SwiftUI

// MARK: - ViewModel

extension CheckBoxView {
    
    class ViewModel: ObservableObject {
        
        @Published var isChecked: Bool
        
        let lineWidth: CGFloat
        let strokeColor: Color
        
        var strokeStyle: StrokeStyle {
            
            .init(
                lineWidth: lineWidth,
                lineCap: .round,
                dash: [123],
                dashPhase: dashPhase
            )
        }
        
        private var dashPhase: CGFloat {
            isChecked == false ? 0 : 70
        }
        
        init(_ isChecked: Bool, lineWidth: CGFloat, strokeColor: Color) {
            
            self.isChecked = isChecked
            self.lineWidth = lineWidth
            self.strokeColor = strokeColor
        }

        convenience init(_ isChecked: Bool = false) {
            
            self.init(
                isChecked,
                lineWidth: 1.25,
                strokeColor: .mainColorsGray
            )
        }
        
        func toggle() {
            isChecked.toggle()
        }
    }
}

// MARK: - View

struct CheckBoxView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 3)
                .trim(from: 0, to: 1)
                .stroke(style: viewModel.strokeStyle)
                .foregroundColor(viewModel.strokeColor)
                .frame(width: 18, height: 18)
            
            if viewModel.isChecked == true {
                CheckView(viewModel: viewModel)
            }
        }
        .animation(nil, value: viewModel.isChecked)
        .contentShape(Rectangle())
        .onTapGesture {
            
            viewModel.toggle()
            
        }.frame(width: 24, height: 24)
    }
}

extension CheckBoxView {
    
    struct CheckView: View {
        
        let viewModel: ViewModel
        
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
                .stroke(lineWidth: viewModel.lineWidth)
                .foregroundColor(viewModel.strokeColor)
            }
            .offset(x: 0, y: 1.5)
            .frame(width: 20, height: 20)
        }
    }
}

// MARK: - Preview

struct CheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CheckBoxView(viewModel: .init(true))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
