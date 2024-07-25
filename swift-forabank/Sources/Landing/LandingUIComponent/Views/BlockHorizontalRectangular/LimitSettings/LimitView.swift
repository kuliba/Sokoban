//
//  LimitView.swift
//
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import TextFieldComponent
import Combine
import SwiftUI

struct LimitView<InfoView>: View
where InfoView: View {
    
    @StateObject private var textFieldModel: DecimalTextFieldWithValueViewModel
        
    let state: State
    let event: (LimitEvent) -> Void
    let infoView: () -> InfoView
    let makeIconView: ViewFactory.MakeIconView

    let config: LimitConfig
    
    private let getDecimal: (TextFieldState) -> Decimal
    
    init(
        state: State,
        event: @escaping (LimitEvent) -> Void,
        currencySymbol: String,
        config: LimitConfig,
        infoView: @escaping () -> InfoView,
        makeIconView: @escaping ViewFactory.MakeIconView
    ) {
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol
        )
        let textField = DecimalTextFieldWithValueViewModel.decimal(
            formatter: formatter,
            maxValue: state.limit.value
        )
        
        self._textFieldModel = .init(wrappedValue: textField)
        self.getDecimal = formatter.getDecimal
        self.state = state
        self.event = event
        self.config = config
        self.infoView = infoView
        self.makeIconView = makeIconView
    }
        
    var body: some View {
        
        limitView()
    }
    
    private func limitView() -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            state.limit.title.text(withConfig: config.title)
                .frame(height: 24)
            HStack {
                makeIconView(state.limit.md5Hash)
                    .aspectRatio(contentMode: .fit)
                    .frame(widthAndHeight: config.widthAndHeight)
                
                textField()
            }
            .frame(height: 46)
            infoView()
                .hidden(state.hiddenInfo)
        }
    }

    @ViewBuilder
    private func textField() -> some View {
        
        let textFieldPublisher = textFieldModel.$state
            .map(getDecimal)
            .removeDuplicates(by: decimalEqual)
        
        TextFieldView(
            viewModel: textFieldModel,
            textFieldConfig: .init(
                font: .systemFont(ofSize: 16),
                textColor: config.limit.textColor,
                tintColor: .init(red: 28/255, green: 28/255, blue: 28/255),
                backgroundColor: .clear,
                placeholderColor: .clear
            )
        )
        .onReceive(textFieldPublisher) {
            event(.edit($0))
            /*state.hiddenInfo = limit.value >= $0 // TODO: remove, only test*/
        }
    }
}

extension LimitView {
    
    typealias State = LimitSettingsState
    typealias Event = LimitEvent
}

// MARK: - Helpers

private func decimalEqual(
    _ lhs: Decimal,
    _ rhs: Decimal
) -> Bool {

    let lhs = NSDecimalNumber(decimal: lhs)
    let rhs = NSDecimalNumber(decimal: rhs)
    
    return lhs.compare(rhs) == .orderedSame
}

// MARK: - Previews

struct LimitView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 32) {
                        
            LimitView(
                state: .init(hiddenInfo: false, limit: .preview),
                event: { print($0) },
                currencySymbol: "₽",
                config: .preview,
                infoView: {
                    
                    Text("Info View here")
                        .font(.caption)
                        .foregroundColor(.pink)
                }, 
                makeIconView: { _ in .init(
                    image: .flag,
                    publisher: Just(.percent).eraseToAnyPublisher()
                )}
            )
        }
    }
}

extension View {
    
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        
        switch isHidden {
        case true: self.hidden()
        case false: self
        }
    }
}
