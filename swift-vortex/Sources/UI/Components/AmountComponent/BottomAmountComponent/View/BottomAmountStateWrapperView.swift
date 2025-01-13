//
//  BottomAmountStateWrapperView.swift
//
//
//  Created by Igor Malyarov on 20.06.2024.
//

import SwiftUI
import TextFieldComponent
import SharedConfigs

public struct BottomAmountStateWrapperView<InfoView>: View
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
        
        HStack(spacing: 24) {
            
            amountView()
            buttonView(action: { viewModel.event(.button(.tap)) })
        }
        .padding(frameInsets)
        .background(config.backgroundColor.ignoresSafeArea())
    }
}

public extension BottomAmountStateWrapperView {
    
    typealias ViewModel = BottomAmountViewModel
    typealias Config = BottomAmountConfig
}

private extension BottomAmountStateWrapperView {
    
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
            .disabled(!viewModel.state.button.isEnabled)
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
        
        viewModel.state.button.isEnabled
        ? config.button.active
        : config.button.inactive
    }
}

struct BottomAmountStateWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
            
            preview(value: 99.9, .enabled)
            preview(value: 9, .enabled, .tapped)
            preview(value: 9_876.54, .disabled)
        }
    }
    
    static func preview(
        currencySymbol: String = "₽",
        value: Decimal = 12.34,
        _ button: BottomAmount.AmountButton = .enabled,
        _ status: BottomAmount.Status? = nil
    ) -> some View {
        
        Demo(viewModel: viewModel(
            currencySymbol: currencySymbol,
            bottomAmount: .preview(value, button, status)
        ))
    }
    
    private static func viewModel(
        currencySymbol: String = "₽",
        bottomAmount: BottomAmount
    ) -> BottomAmountViewModel {
        
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol
        )
        let textField = DecimalTextFieldViewModel.decimal(
            formatter: formatter
        )
        let reducer = BottomAmountReducer()
        
        return .init(
            initialState: bottomAmount,
            reduce: reducer.reduce(_:_:),
            formatter: formatter,
            textFieldModel: textField
        )
    }
}

private struct Demo: View {
    
    @StateObject var viewModel: BottomAmountViewModel
    
    private var isEnabled: Bool { viewModel.state.button.isEnabled }
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            HStack {
                
                Button("set to 1234.56") {
                    
                    viewModel.event(.edit(1234.56))
                }
                
                Button(isEnabled ? "disable" : "enable") {
                    
                    viewModel.event(.button(.setActive(!isEnabled)))
                }
            }
            
            BottomAmountStateWrapperView(
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
