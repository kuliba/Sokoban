//
//  FooterStateWrapperView.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import SwiftUI
import TextFieldComponent
import SharedConfigs

public struct FooterStateWrapperView<InfoView>: View
where InfoView: View {
    
    @StateObject private var viewModel: ViewModel
    @StateObject private var textFieldModel: DecimalTextFieldViewModel
    
    private let config: Config
    private let infoView: () -> InfoView
    
    public init(
        viewModel: ViewModel,
        config: Config,
        infoView: @escaping () -> InfoView
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self._textFieldModel = .init(wrappedValue: viewModel.textFieldModel)
        self.config = config
        self.infoView = infoView
    }
    
    private let frameInsets = EdgeInsets(
        top: 4,
        leading: 20,
        bottom: 16,
        trailing: 19
    )
    
    public var body: some View {
        
        switch viewModel.state.style {
        case .amount:
            withAmountView()
            
        case .button:
            withButtonView()
        }
    }
}

public extension FooterStateWrapperView {
    
    typealias ViewModel = FooterViewModel
    typealias Config = BottomAmountConfig
}

private extension FooterStateWrapperView {
    
    func withAmountView() -> some View {
        
        HStack(spacing: 24) {
            
            amountView()
            buttonView(action: { viewModel.event(.button(.tap)) })
        }
        .padding(frameInsets)
        .background(config.backgroundColor.ignoresSafeArea())
    }
    
    func amountView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            config.title.text(withConfig: config.titleConfig)
            textField()
            Divider().background(config.dividerColor)
                .padding(.top, 4)
            infoView()
        }
    }
    
    func textField() -> some View {
        
        TextFieldView(
            viewModel: textFieldModel,
            textFieldConfig: .init(
                font: config.amountFont,
                textColor: config.amount.textColor,
                tintColor: .accentColor,
                backgroundColor: .clear,
                placeholderColor: .clear
            )
        )
    }
    
    func buttonView(
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action, label: buttonLabel)
            .disabled(viewModel.state.isDisabled)
    }
    
    private func buttonLabel() -> some View {
        
        ZStack {
            
            buttonStateConfig.color
                .frame(config.buttonSize)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            viewModel.state.button.title.text(withConfig: buttonStateConfig.text)
        }
    }
    
    private var buttonStateConfig: ButtonStateConfig {
        
        switch viewModel.state.button.state {
        case .active:   return config.button.active
        case .inactive: return config.button.inactive
        case .tapped:   return config.button.tapped
        }
    }
}

private extension FooterStateWrapperView {
    
    private func withButtonView() -> some View {
        
        FooterButtonView(
            state: viewModel.state.button,
            event: { viewModel.event(.button(.tap)) },
            config: config.button
        )
        .disabled(viewModel.state.isDisabled)
    }
}

private extension FooterState {
    
    var isDisabled: Bool { button.state != .active }
}

struct FooterStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 32) {
                
                previewButton(.active)
                previewButton(.inactive)
                previewButton(.tapped)
            }
            .padding(.horizontal)
            
            VStack(spacing: 32) {
                
                preview(99.9, .active)
                preview(9, .tapped)
                preview(9_876.54, .inactive)
            }
        }
    }
    
    static func previewButton(
        _ buttonState: FooterState.FooterButton.ButtonState
    ) -> some View {
        
        preview(99.9, buttonState, style: .button)
    }
    
    static func preview(
        currency: String = "₽",
        _ amount: Double = 12.34,
        title: String = "Pay",
        _ buttonState: FooterState.FooterButton.ButtonState = .active,
        style: FooterState.Style = .amount
    ) -> some View {
        
        Demo(viewModel: .init(
            currencySymbol: currency,
            initialState: .init(
                amount: .init(amount),
                button: .init(title: title, state: buttonState),
                style: style
            )
        ))
    }
}

private struct Demo: View {
    
    @StateObject var viewModel: FooterViewModel
    
    private var isEnabled: Bool { !viewModel.state.isDisabled }
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            HStack {
                
                Group {
                    
                    Button("set to 1234.56") {
                        
                        viewModel.event(.edit(1234.56))
                    }
                    
                    Button("Activate") { viewModel.event(.button(.enable)) }
                    Button("Deactivate") { viewModel.event(.button(.disable)) }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            FooterStateWrapperView(
                viewModel: viewModel,
                config: .preview,
                infoView: {
                    
                    Text("Возможна комиссия")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            )
        }
    }
}
