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
        
        @Published private(set) var isChecked: Bool
        
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
        
        init(with parameterCheck: Payments.ParameterCheck) {
            
            self.isChecked = parameterCheck.value
            self.title = parameterCheck.title
            self.link = .init(with: parameterCheck)
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
            normalView()
        case .abroad:
            
            abroadView()
        }
    }
    
    private func normalView() -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 18) {
                
                checkBoxView()
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(titleColor)
                
                Spacer()
            }
            .onTapGesture(perform: viewModel.toggleCheckbox)
            
            viewModel.link.map { link in
                
                Text(link.title)
                    .underline()
                    .font(.textBodyMR14200())
                    .foregroundColor(.textSecondary)
                    .padding(.leading, 42)
                    .onTapGesture { openURL(link.url) }
            }
        }
    }
    
    private func abroadView() -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 18) {
                
                checkBoxView()
                
                HStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textPlaceholder)
                    
                    viewModel.link.map { link in
                        
                        Text(link.title)
                            .underline()
                            .font(.textBodyMR14200())
                            .foregroundColor(.textSecondary)
                            .onTapGesture { openURL(link.url) }
                    }
                    
                    Text(viewModel.abroadFamiliarizedTitle)
                        .font(.textBodyMR14200())
                        .foregroundColor(.textPlaceholder)
                }
                
                Spacer()
            }
            .onTapGesture(perform: viewModel.toggleCheckbox)
        }
    }
    
    private func checkBoxView() -> some View {
        
        CheckBoxView(
            isChecked: .init(
                get: { viewModel.isChecked },
                set: { viewModel.setCheckbox(to: $0) }
            ),
            activeColor: checkBoxActiveColor
        )
    }
}

extension PaymentsCheckView {
    
    struct CheckBoxView: View {
        
        @Binding var isChecked: Bool
        
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
            
            PaymentsCheckView(viewModel: .abroad)
            
            PaymentsCheckView(viewModel: .spb(isChecked: true))
            PaymentsCheckView(viewModel: .spb(isChecked: false))
                        
            PaymentsCheckView(
                viewModel: .preview(
                    true,
                    title: "Подтверждаю, что источником перевода не являются средства от полученных дивидендов (распределения прибыли) от российских АО, ООО, хозяйственных товариществ и производственных кооперативов"
                )
            )
            PaymentsCheckView(
                viewModel: .preview(
                    false,
                    title: "Подтверждаю, что источником перевода не являются средства от полученных дивидендов (распределения прибыли) от российских АО, ООО, хозяйственных товариществ и производственных кооперативов"
                )
            )
            PaymentsCheckView(
                viewModel: .preview(
                    false,
                    title: "Подтверждаю, что источником перевода не являются средства от полученных дивидендов (распределения прибыли) от российских АО, ООО, хозяйственных товариществ и производственных кооперативов",
                    style: .c2bSubscribtion
                )
            )
            PaymentsCheckView(
                viewModel: .preview(
                    false,
                    title: "Подтверждаю, что источником перевода не являются средства от полученных дивидендов (распределения прибыли) от российских АО, ООО, хозяйственных товариществ и производственных кооперативов",
                    mode: .abroad
                )
            )
        }
        .padding()
        .previewLayout(.fixed(width: 375, height: 100))
    }
}

// MARK: - Sample Content

extension PaymentsCheckView.ViewModel {
    
    static let sample = preview(true)
    static let sampleUnchecked = preview(false)
    
    static let abroad = preview(true, title: "C договором", linkTitle: "оферты", mode: .abroad)
    
    static func spb(
        isChecked: Bool
    ) -> PaymentsCheckView.ViewModel {
        
        preview(
            isChecked,
            title: "Включить переводы через СБП, ",
            linkTitle: "принять условия обслуживания",
            style: .c2bSubscribtion
        )
    }
    
    static func preview(
        _ isChecked: Bool,
        title: String = "Оплата ЖКХ",
        linkTitle: String? = nil,
        style: Payments.ParameterCheck.Style = .regular,
        mode: Payments.ParameterCheck.Mode = .normal
    ) -> PaymentsCheckView.ViewModel {
        
        .init(
            with: .init(
                .init(id: "checkBoxID", value: "\(isChecked)"),
                title: title,
                link: linkTitle.map { .init(title: $0, url: .google) },
                style: style,
                mode: mode,
                group: nil
            )
        )
    }
}

private extension URL {
    
    static let google: Self = .init(string: "https://www.google.com")!
}
