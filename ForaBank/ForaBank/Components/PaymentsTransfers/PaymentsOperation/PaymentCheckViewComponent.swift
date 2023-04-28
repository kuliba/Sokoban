//
//  PaymentCheckBoxViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.12.2022.
//

import Foundation
import SwiftUI

// MARK: - ViewModel

extension PaymentsCheckView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published var isChecked: Bool
        let title: String
        let link: LinkViewModel?
        let style: Style
        let mode: Mode
        let abroadFamiliarizedTitle = "ознакомлен"
        
        var parameterCheck: Payments.ParameterCheck? { source as? Payments.ParameterCheck }
        
        override var isValid: Bool {
            
            guard let parameterCheck = parameterCheck else {
                return true
            }
            
            switch parameterCheck.mode {
            case .abroad: return isChecked
            default: return true
            }
        }
        
        init(_ isChecked: Bool, title: String, link: LinkViewModel?, style: Style, mode: Mode = .normal, source: PaymentsParameterRepresentable = Payments.ParameterMock()) {
            
            self.isChecked = isChecked
            self.title = title
            self.link = link
            self.style = style
            self.mode = mode
            super.init(source: source)
        }
        
        convenience init(with parameterCheck: Payments.ParameterCheck) {
            
            self.init(parameterCheck.value, title: parameterCheck.title, link: .init(with: parameterCheck), style: .init(with: parameterCheck), mode: .init(with: parameterCheck), source: parameterCheck)
            bind()
        }
    }
}

//MARK: - Types

extension PaymentsCheckView.ViewModel {
    
    struct LinkViewModel {
        
        let title: String
        let url: URL
        
        init(title: String, url: URL) {
            
            self.title = title
            self.url = url
        }
        
        init?(with parameter: Payments.ParameterCheck) {
            
            guard let link = parameter.link else {
                return nil
            }
            
            self.init(title: link.title, url: link.url)
        }
    }
    
    enum Style {
        
        case regular
        case c2bSubscription
        
        init(with parameter: Payments.ParameterCheck) {
            
            switch parameter.style {
            case .regular:
                self = .regular
                
            case .c2bSubscribtion:
                self = .c2bSubscription
            }
        }
    }
    
    enum Mode {
        
        case normal
        case abroad
        
        init(with parameter: Payments.ParameterCheck) {
            
            switch parameter.mode {
            case .abroad:
                self = .abroad
                
            case .normal:
                self = .normal
            }
        }
    }
}

//MARK: - Binding

extension PaymentsCheckView.ViewModel {
    
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

struct PaymentsCheckView: View {
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.openURL) var openURL
    
    var titleColor: Color {
        
        switch viewModel.style {
        case .regular: return .textSecondary
        case .c2bSubscription: return .textPlaceholder
        }
    }
    
    var checkBoxActiveColor: Color {
        
        switch viewModel.style {
        case .regular: return .systemColorActive
        case .c2bSubscription: return .iconGray
        }
    }

    var body: some View {
        
        switch viewModel.mode {
        case .normal:
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: 18) {
                    
                    CheckBoxView(isChecked: $viewModel.isChecked, activeColor: checkBoxActiveColor)
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(titleColor)
      
                    Spacer()
                }
                .onTapGesture {
                    
                    viewModel.isChecked.toggle()
                }
                
                if let link = viewModel.link {
                    
                    Text(link.title)
                        .underline()
                        .font(.textBodyMR14200())
                        .foregroundColor(.textSecondary)
                        .padding(.leading, 42)
                        .onTapGesture {
                            openURL(link.url)
                        }
                }
            }
        case .abroad:
         
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: 18) {
                    
                    CheckBoxView(isChecked: $viewModel.isChecked, activeColor: checkBoxActiveColor)
                    
                    HStack(spacing: 8) {
                        
                        Text(viewModel.title)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textPlaceholder)

                        if let link = viewModel.link {
                            
                            Text(link.title)
                                .underline()
                                .font(.textBodyMR14200())
                                .foregroundColor(.textSecondary)
                                .onTapGesture {
                                    openURL(link.url)
                                }
                        }
                        
                        Text(viewModel.abroadFamiliarizedTitle)
                            .font(.textBodyMR14200())
                            .foregroundColor(.textPlaceholder)
                    }
      
                    Spacer()
                }
                .onTapGesture {
                    
                    viewModel.isChecked.toggle()
                }
            }
        }
    }
}

extension PaymentsCheckView {
    
    struct CheckBoxView: View {
        
        @Binding var isChecked: Bool
        let activeColor: Color
        
        private var srokeStyle: StrokeStyle { StrokeStyle(lineWidth: 1.25, lineCap: .round, dash: [123], dashPhase: isChecked == false ? 0 : 70) }
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 3)
                    .trim(from: 0, to: 1)
                    .stroke(style: srokeStyle)
                    .foregroundColor(isChecked ? activeColor : .iconGray)
                    .frame(width: 18, height: 18)
                
                if isChecked == true {
                    
                    CheckMark()
                        .stroke(lineWidth: 1.25)
                        .foregroundColor(activeColor)
                        .frame(width: 20, height: 20)
                        .offset(x: 0, y: 1.5)
                }
            }
            .frame(width: 24, height: 24)
        }
    }
}

struct CheckMark: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let centerX = rect.midX
        let centerY = rect.midY
        
        let centerPoint: CGPoint = .init(x: centerX, y: centerY)
        let point: CGPoint = .init(x: centerX - 3, y: centerY - 3)
        let endPoint: CGPoint = .init(x: rect.maxX, y: rect.minY)
        
        path.move(to: point)
        path.addLine(to: centerPoint)
        path.addLine(to: endPoint)
        
        return path
    }
}

// MARK: - Preview

struct PaymentsCheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsCheckView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 80))
                .padding()
            
            PaymentsCheckView(viewModel: .init(false, title: "Оплата ЖКХ", link: nil, style: .regular))
                .previewLayout(.fixed(width: 375, height: 80))
                .padding()
            
            PaymentsCheckView(viewModel: .init(true, title: "C договором", link: .init(title: "оферты", url: URL(string: "https://www.google.com")!), style: .regular, mode: .abroad))
                .previewLayout(.fixed(width: 375, height: 80))
                .padding()
            
            PaymentsCheckView(viewModel: .init(false, title: "Включить переводы через СБП, ", link: .init(title: "принять условия обслуживания", url: URL(string: "https://www.google.com")!) ,style: .c2bSubscription))
                .previewLayout(.fixed(width: 375, height: 100))
                .padding()
            
            PaymentsCheckView(viewModel: .init(true, title: "Включить переводы через СБП, ", link: .init(title: "принять условия обслуживания", url: URL(string: "https://www.google.com")!) ,style: .c2bSubscription))
                .previewLayout(.fixed(width: 375, height: 100))
                .padding()
        }
    }
}

//MARK: - Sample Content

extension PaymentsCheckView.ViewModel {
    
    static let sample = PaymentsCheckView.ViewModel(true, title: "Оплата ЖКХ", link: nil, style: .regular)

}
