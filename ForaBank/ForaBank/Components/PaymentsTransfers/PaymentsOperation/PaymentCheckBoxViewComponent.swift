//
//  PaymentCheckBoxViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.12.2022.
//

import Foundation
import SwiftUI

// MARK: - ViewModel

extension PaymentsCheckBoxView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var isChecked: Bool
        let title: String
        
        init(_ isChecked: Bool, title: String, source: PaymentsParameterRepresentable = Payments.ParameterMock()) {
            
            self.title = title
            self.isChecked = isChecked
            super.init(source: source)
        }
        
        convenience init(with parameterSelect: Payments.ParameterCheckBox) throws {
            
            self.init(true, title: parameterSelect.title, source: parameterSelect)
            bind()
        }
    }
}

//MARK: - Binding

extension PaymentsCheckBoxView.ViewModel {
    
    private func bind() {
        
        $isChecked
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] content in
                
                update(value: content.description)
                
            }.store(in: &bindings)
    }
}

//MARK: - Actions
extension PaymentsParameterViewModelAction {
    
    enum CheckBox {
        
        struct ValueDidChanged: Action {
            
            let value: Bool
        }
    }
}

// MARK: - View

struct PaymentsCheckBoxView: View {
    
    @ObservedObject var viewModel: ViewModel
    var srokeStyle: StrokeStyle { StrokeStyle(lineWidth: 1.25, lineCap: .round, dash: [123], dashPhase: viewModel.isChecked == false ? 70 : 0) }
    
    var body: some View {
        
        HStack(spacing: 22) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 3)
                    .trim(from: 0, to: 1)
                    .stroke(style: srokeStyle)
                    .foregroundColor(viewModel.isChecked ? .mainColorsGray : .systemColorActive)
                    .frame(width: 18, height: 18)
                
                if viewModel.isChecked == false {
                    CheckView(viewModel: viewModel)
                }
            }
            .frame(width: 24, height: 24)
            
            Text(viewModel.title)
                .foregroundColor(.textSecondary)
                .font(.textBodyMR14200())
            
            Spacer()
        }
        .onTapGesture {
            
            viewModel.isChecked.toggle()
            
        }
    }
}

extension PaymentsCheckBoxView {
    
    struct CheckView: View {
        
        let viewModel: ViewModel
        
        var body: some View {
            
            GeometryReader { proxy in
                
                CheckMark()
                    .stroke(lineWidth: 1.25)
                    .foregroundColor(viewModel.isChecked ? .mainColorsGray : .systemColorActive)
                
            }
            .offset(x: 0, y: 1.5)
            .frame(width: 20, height: 20)
        }
    }
}

struct CheckMark: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        let center = 20 / 2
        
        let centerPoint: CGPoint = .init(x: center, y: center)
        let point: CGPoint = .init(x: center - 3, y: center - 3)
        let endPoint: CGPoint = .init(x: 20, y: 0)
        
        path.move(to: point)
        path.addLine(to: centerPoint)
        path.addLine(to: endPoint)
        
        return path
    }
}

// MARK: - Preview

struct CheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsCheckBoxView(viewModel: .init(true, title: "Оплата ЖКХ"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
