//
//  PaymentCheckBoxViewComponent.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 09.12.2022.
//

import Foundation
import LinkableText
import SwiftUI

// MARK: - ViewModel

extension PaymentsCheckView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published private(set) var isChecked: Bool
        
        let title: String
        let urlString: String?
        let style: Style
        let mode: Mode
        
        var parameterCheck: Payments.ParameterCheck? {
            source as? Payments.ParameterCheck
        }
        
        override var isValid: Bool {
            
            guard let parameterCheck else {
                return true
            }
            
            switch parameterCheck.mode {
            case .abroad:     return isChecked
            case .requisites: return true
            default:          return isChecked
            }
        }
        
        init(with parameterCheck: Payments.ParameterCheck) {
            
            self.isChecked = parameterCheck.value
            self.title = parameterCheck.title
            self.urlString = parameterCheck.urlString
            self.style = .init(with: parameterCheck)
            self.mode = .init(with: parameterCheck)
            
            super.init(source: parameterCheck)
            
            bind()
        }
        
        func toggleCheckbox() {
            
            DispatchQueue.main.async {
                
                self.isChecked.toggle()
            }
        }
        
        func setCheckbox(to value: Bool) {
            
            DispatchQueue.main.async {
                
                self.isChecked = value
            }
        }
    }
}

// MARK: - Types

extension PaymentsCheckView.ViewModel {
    
    enum Style {
        
        case regular
        case c2bSubscription
        
        init(with parameter: Payments.ParameterCheck) {
            
            switch parameter.style {
            case .regular:
                self = .regular
                
            case .c2bSubscription:
                self = .c2bSubscription
            }
        }
    }
    
    enum Mode {
        
        case abroad
        case requisites
        case normal
        
        init(with parameter: Payments.ParameterCheck) {
            
            switch parameter.mode {
            case .abroad:
                self = .abroad
                
            case .requisites:
                self = .requisites
                
            case .normal:
                self = .normal
            }
        }
    }
}

// MARK: - Binding

extension PaymentsCheckView.ViewModel {
    
    private func bind() {
        
        $isChecked
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] content in
                
                update(value: content.description)
                
            }.store(in: &bindings)
    }
}

// MARK: - Actions

extension PaymentsParameterViewModelAction {
    
    enum CheckBox {
        
        struct ValueDidChanged: Action {
            
            let value: Bool
        }
    }
}

// MARK: - View

struct PaymentsCheckView: View {
    
    @Environment(\.openURL) var openURL
    
    @ObservedObject var viewModel: ViewModel
    
    var titleColor: Color {
        
        switch viewModel.style {
        case .regular:         return .textSecondary
        case .c2bSubscription: return .textPlaceholder
        }
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 18) {
            
            checkBoxView()
            linkableTextView()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func checkBoxView() -> some View {
        
        CheckBoxView(
            isChecked: viewModel.isChecked,
            activeColor: .systemColorActive
        )
        .onTapGesture(perform: viewModel.toggleCheckbox)
    }
    
    private func linkableTextView() -> some View {
        
        LinkableTextView(
            title: viewModel.title,
            urlString: viewModel.urlString,
            handleURL: { openURL($0) }
        )
        .font(.textBodyMR14200())
        .foregroundColor(.textPlaceholder)
        .accentColor(.textSecondary)
    }
}

extension PaymentsCheckView {
    
    struct CheckBoxView: View {
        
        let isChecked: Bool
        let activeColor: Color
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 3)
                    .trim(from: 0, to: 1)
                    .stroke(style: strokeStyle)
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
        
        private var strokeStyle: StrokeStyle {
            
            .init(
                lineWidth: 1.25,
                lineCap: .round,
                dash: [123],
                dashPhase: isChecked == false ? 0 : 70
            )
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

// MARK: - Adapter

private extension LinkableTextView {
    
    init(
        title: String,
        urlString: String?,
        tag: (String, String) = ("<u>", "</u>"),
        handleURL: @escaping (URL) -> Void
    ) {
        self.init(
            taggedText: title,
            urlString: urlString ?? " ",
            tag: tag,
            handleURL: handleURL
        )
    }
}

// MARK: - Preview

struct PaymentsCheckBoxView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            previewsGroup()
            
            VStack(content: previewsGroup)
                .previewDisplayName("Xcode 14+")
        }
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            
            PaymentsCheckView(viewModel: .sample)
            PaymentsCheckView(viewModel: .sampleUnchecked)
            
            PaymentsCheckView(viewModel: .preview(
                isChecked: true,
                title: "C договором",
                linkTitle: "оферты",
                mode: .abroad
            ))
            
            PaymentsCheckView(viewModel: .spb(isChecked: true))
            PaymentsCheckView(viewModel: .spb(isChecked: false))
            
            PaymentsCheckView(viewModel: .preview(isChecked: true))
            PaymentsCheckView(viewModel: .preview(isChecked: false))
            PaymentsCheckView(viewModel: .preview(isChecked: false, style: .c2bSubscription))
            PaymentsCheckView(viewModel: .preview(isChecked: false, mode: .abroad))
        }
        .padding(.horizontal)
    }
}

// MARK: - Sample Content

extension PaymentsCheckView.ViewModel {
    
    static let sample = preview(isChecked: true, title: "Оплата ЖКХ")
    static let sampleUnchecked = preview(isChecked: false, title: "Оплата ЖКХ")
    
    static func spb(
        isChecked: Bool
    ) -> PaymentsCheckView.ViewModel {
        
        preview(
            isChecked: isChecked,
            title: "Включить переводы через СБП, ",
            linkTitle: "принять условия обслуживания",
            style: .c2bSubscription
        )
    }
    
    static func preview(
        isChecked: Bool,
        title: String = "Подтверждаю, что источником перевода не являются средства от полученных дивидендов (распределения прибыли) от российских АО, ООО, хозяйственных товариществ и производственных кооперативов",
        linkTitle: String? = nil,
        style: Payments.ParameterCheck.Style = .regular,
        mode: Payments.ParameterCheck.Mode = .normal
    ) -> PaymentsCheckView.ViewModel {
        
        .init(
            with: .init(
                .init(id: "checkBoxID", value: "\(isChecked)"),
                title: title,
                urlString: "https://www.google.com",
                style: style,
                mode: mode,
                group: nil
            )
        )
    }
}
