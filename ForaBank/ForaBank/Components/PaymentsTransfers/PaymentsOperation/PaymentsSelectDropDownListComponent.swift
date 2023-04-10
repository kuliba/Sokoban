//
//  PaymentsSelectDropDownList.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 09.02.2023.
//

import Foundation
import SwiftUI

extension PaymentSelectDropDownView {
    
    class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        @Published private(set) var selectedOption: SelectedOptionViewModel
        @Published private(set) var options: [OptionViewModel]?
        
        var hasOptions: Bool { options != nil }
        
        var parameterDropDownList: Payments.ParameterSelectDropDownList? {
            source as? Payments.ParameterSelectDropDownList
        }
        
        init(selectedOption: SelectedOptionViewModel, options: [OptionViewModel]?, source: PaymentsParameterRepresentable = Payments.ParameterMock(id: UUID().uuidString)) {
            
            self.selectedOption = selectedOption
            self.options = options
            super.init(source: source)
        }
        
        convenience init?(with parameterSelect: Payments.ParameterSelectDropDownList) {
            
            guard let selectedOption = SelectedOptionViewModel(with: parameterSelect)
            else { return nil }
            
            self.init(
                selectedOption: selectedOption,
                options: nil,
                source: parameterSelect
            )
            
            if parameterSelect.isActive {
                
                self.selectedOption.button = .init(
                    action: { [weak self] in
                        
                        self?.action.send(PaymentSelectDropDownView.ViewModel.ShowOptions())
                    },
                    mode: .active
                )
            }
            
            bind()
        }
        
        func isSelected(_ item: OptionViewModel) -> Bool {
            
            item.option.id == selectedOption.option.id
        }
        
        struct Option: Identifiable {
            
            let id: String
            let icon: Image?
            let title: String
        }
        
        struct OptionViewModel: Identifiable {
            
            let option: Option
            let title: String
            let action: (OptionViewModel.ID) -> Void
            
            var id: String { option.id }
            var icon: Image? { option.icon }
        }
        
        struct SelectedOptionViewModel {
            
            let option: Option
            let title: String
            
            var button: ButtonViewModel

            var icon: Image? { option.icon }
            var selectTitle: String { option.title }
            
            struct ButtonViewModel {
                
                let action: () -> Void
                let mode: Mode
                
                enum Mode {
                    
                    case active
                    case inactive
                }
            }
        }
    }
}

private extension PaymentSelectDropDownView.ViewModel.Option {
    
    init(with option: Payments.ParameterSelectDropDownList.Option) {
        
        self.init(id: option.id, icon: option.icon?.image, title: option.name)
    }
}

private extension PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel {
    
    init?(with parameterSelect: Payments.ParameterSelectDropDownList) {
        
        guard let defaultOption = parameterSelect.options.first(where: { $0.id == parameterSelect.value })
        else { return nil }
        
        self.init(
            option: .init(with: defaultOption),
            title: parameterSelect.title,
            button: .init(
                action: {},
                mode: parameterSelect.options.mode
            )
        )
    }
}

private extension Array where Element == Payments.ParameterSelectDropDownList.Option {
    
    typealias Mode = PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel.ButtonViewModel.Mode
    
    var mode: Mode {
        
        count > 1 ? .active : .inactive
    }
}

private extension Payments.ParameterSelectDropDownList {
    
    var isActive: Bool {
        
        options.mode == .active
    }
}

extension PaymentSelectDropDownView.ViewModel {
    
    private func bind() {
        
        action
            .compactMap { $0 as? PaymentSelectDropDownView.ViewModel.ShowOptions }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                withAnimation {
                    
                    self.options = toggledOptions()
                }
            }
            .store(in: &bindings)
        
        action
            .compactMap { $0 as? PaymentSelectDropDownView.ViewModel.DidSelectOption }
            .map(\.id)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] id in
                
                guard let parameter = parameterDropDownList,
                      let selectedOption = PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel(with: parameter)
                else { return }
                
                self.update(value: id)
                
                withAnimation {
                    
                    self.selectedOption = selectedOption
                    
                    self.options = nil
                }
            }
            .store(in: &bindings)
    }
    
    private func toggledOptions() -> [OptionViewModel]? {
        
        if self.options != nil {
            
            return nil
            
        } else {
            
            return parameterDropDownList?
                .options
                .map {
                    .init(
                        option: .init(with: $0),
                        title: $0.name,
                        action: { [weak self] id in
                            
                            self?.action.send(PaymentSelectDropDownView.ViewModel.DidSelectOption(id: id))
                        }
                    )
                }
        }
    }
}

extension PaymentSelectDropDownView.ViewModel {
    
    struct ShowOptions: Action {}
    
    struct DidSelectOption: Action {
        
        let id: PaymentSelectDropDownView.ViewModel.OptionViewModel.ID
    }
}

struct PaymentSelectDropDownView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            SelectedOptionView(
                selectedOption: viewModel.selectedOption,
                hasOptions: viewModel.hasOptions
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: viewModel.selectedOption.button.action)
            
            if let options = viewModel.options {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    ForEach(options) { item in
                        
                        OptionView(viewModel: item, isSelected: viewModel.isSelected(item))
                            .contentShape(Rectangle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
    
    struct OptionView: View {
        
        let viewModel: ViewModel.OptionViewModel
        let isSelected: Bool
        
        var body: some View {
            
            VStack(spacing: 12) {
                
                HStack(spacing: 16) {
                    
                    iconView
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.title)
                        .foregroundColor(.textWhite)
                        .font(.textH4M16240())
                    
                    Spacer()
                    
                    Image(radioIconName)
                        .renderingMode(.template)
                        .foregroundColor(radioIconColor)
                        .frame(width: 24, height: 24)
                }
                
                Divider()
                    .overlay(
                        Color.mainColorsGray.opacity(0.2)
                            .frame(height: 1)
                    )
                    .padding (.leading, 40)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                
                viewModel.action(viewModel.id)
            }
            .frame(height: 46, alignment: .bottom)
        }
        
        @ViewBuilder
        private var iconView: some View {
            
            if let icon = viewModel.icon {
                
                icon
                    .resizable()
                    .foregroundColor(.iconGray)
                
            } else {
                
                Color.clear
            }
        }
        
        //TODO: load placeholder icon from StyleGuide
        private var radioIconName: String { isSelected ? "Payments Icon Circle Selected" : "Payments Icon Circle Empty" }
        
        private var radioIconColor: Color { isSelected ? .buttonPrimary : .mainColorsGray }
    }
    
    struct SelectedOptionView: View {
        
        let selectedOption: PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel
        let hasOptions: Bool
        
        var body: some View {
            
            HStack(spacing: 16) {
                
                iconView
                    .frame(width: 32, height: 32)
                                
                VStack(spacing: 8) {
                    
                    Text(selectedOption.title)
                        .font(.textBodyMR14180())
                        .foregroundColor(.textPlaceholder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(selectedOption.selectTitle)
                        .font(.textH4M16240())
                        .foregroundColor(hasOptions ? .textPrimary : .textWhite)
                        .frame(alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Button(action: selectedOption.button.action, label: chevronButtonLabel)
                    .allowsHitTesting(isActive)
            }
        }
        
        @ViewBuilder
        private var iconView: some View {
            
            if let icon = selectedOption.icon {
                
                icon
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.iconGray)
                    .frame(width: 24, height: 24)
                    .opacity(hasOptions ? 0.2 : 1)
                
            } else {
                
                Color.clear
            }
        }
        
        private var isActive: Bool { selectedOption.button.mode == .active }
        
        @ViewBuilder
        private func chevronButtonLabel() -> some View {
            
            let rotation: Angle = isActive
            ? .degrees(hasOptions ? -90 : 90)
            : .degrees(90)
            let opacity = isActive ? 1 : 0.2
            
            Image.ic24ChevronRight
                .foregroundColor(.iconGray)
                .rotationEffect(rotation)
                .opacity(opacity)
                .frame(width: 24, height: 24)
        }
    }
}


// MARK: - Preview

struct PaymentSelectDropDownView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            previewGroup()
            
            VStack(content: previewGroup)
                .previewDisplayName("Xcode 14")
        }
        .previewLayout(.sizeThatFits)
    }
    
    private static func previewGroup() -> some View {
        
        Group {
            
            PaymentSelectDropDownView(viewModel: .sample)
            
            PaymentSelectDropDownView(viewModel: .sampleMultiple)
        }
        .padding()
        .background(Color.mainColorsBlack)
    }
}

//MARK: - Preview Content

extension PaymentSelectDropDownView.ViewModel {
    
    static let sample = PaymentSelectDropDownView.ViewModel(
        selectedOption: .preview(button: .preview(icon: .ic16ChevronRight, mode: .inactive)),
        options: nil
    )
    
    static let sampleMultiple = PaymentSelectDropDownView.ViewModel(
        selectedOption: .preview(button: .preview(icon: .ic24ChevronRight, mode: .active)),
        options: .preview
    )
}

private extension PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel {
    
    static func preview(
        button: PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel.ButtonViewModel
    ) -> PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel {
        
        .init(
            option: .init(
                id: "1",
                icon: .ic24Phone,
                title: "По номеру телефона"
            ),
            title: "Перевести",
            button: button
        )
    }
}

private extension PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel.ButtonViewModel {
    
    static func preview(
        icon: Image,
        mode: Mode
    ) -> PaymentSelectDropDownView.ViewModel.SelectedOptionViewModel.ButtonViewModel {
        
        .init(action: {}, mode: mode)
    }
}

private extension Array where Element == PaymentSelectDropDownView.ViewModel.OptionViewModel {
    
    static let preview: Self = [
        .init(option: .byName, title: "По ФИО", action: {_ in }),
        .init(option: .byPhone, title: "По номеру телефона", action: {_ in })
    ]
}

private extension PaymentSelectDropDownView.ViewModel.Option {
    
    static let byName: Self = .init(id: "1", icon: nil, title: "По ФИО")
    static let byPhone: Self = .init(id: "2", icon: .ic24Phone, title: "По номеру телефона")
}
