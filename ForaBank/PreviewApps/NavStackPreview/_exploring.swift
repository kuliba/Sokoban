//
//  _exploring.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import RxViewModel
import SwiftUI

struct _LastPayment: Equatable, Identifiable {
    
    let id: String
}

struct _UtilityService: Equatable, Identifiable {
    
    let id: String
}

struct _Operator: Equatable, Identifiable {
    
    let id: String
}

// MARK: - _UtilityPrepaymentPicker

struct _UtilityPrepaymentPickerState: Equatable {
    
    let lastPayments: [_LastPayment]
    let operators: [_Operator] // non empty
}

enum _UtilityPrepaymentPickerEvent: Equatable {
    
    case complete(Complete)
}

extension _UtilityPrepaymentPickerEvent {
    
    enum Complete: Equatable {
        
        case addCompany
        case payByInstructions
        case select(Select)
    }
}

extension _UtilityPrepaymentPickerEvent.Complete {
    
    enum Select: Equatable {
        
        case lastPayment(_LastPayment)
        case `operator`(_Operator)
    }
}

enum _UtilityPrepaymentPickerEffect {}

final class _UtilityPrepaymentPickerReducer {}

extension _UtilityPrepaymentPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .complete(complete):
            (state, effect) = reduce(state, complete)
        }
        
        return (state, effect)
    }
}

extension _UtilityPrepaymentPickerReducer {
    
    typealias State = _UtilityPrepaymentPickerState?
    typealias Event = _UtilityPrepaymentPickerEvent
    typealias Effect = _UtilityPrepaymentPickerEffect
}

private extension _UtilityPrepaymentPickerReducer {
    
    func reduce(
        _ state: State,
        _ event: Event.Complete
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .addCompany:
            fatalError()
            
        case .payByInstructions:
            fatalError()
            
        case let .select(select):
            (state, effect) = reduce(state, select)
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: Event.Complete.Select
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .lastPayment(lastPayment):
            fatalError()
            
        case let .operator(`operator`):
            fatalError()
        }
        
        return (state, effect)
    }
}

final class _UtilityPrepaymentPickerEffectHandler {}

extension _UtilityPrepaymentPickerEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension _UtilityPrepaymentPickerEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = _UtilityPrepaymentPickerEvent
    typealias Effect = _UtilityPrepaymentPickerEffect
}

struct _UtilityPrepaymentPicker: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        VStack {
            
            if let state, !state.operators.isEmpty {
                factory.makeOperatorPicker((state.lastPayments, state.operators))
            } else {
                factory.makeFooterView()
            }
        }
    }
}

extension _UtilityPrepaymentPicker {
    
    typealias State = _UtilityPrepaymentPickerState?
    typealias Event = _UtilityPrepaymentPickerEvent
    typealias Config = _UtilityPrepaymentPickerConfig
    typealias Factory = _UtilityPrepaymentPickerFactory
}

struct _UtilityPrepaymentPickerConfig: Equatable {
    
    let operatorPicker: _OperatorPickerConfig
    let footer: _FooterViewConfig
    let lastPayment: _LastPaymentViewConfig
    let `operator`: _OperatorViewConfig
}

struct _UtilityPrepaymentPickerFactory {
    
    let makeFooterView: MakeFooterView
    let makeOperatorPicker: MakeOperatorPicker
}

extension _UtilityPrepaymentPickerFactory {
    
    typealias MakeFooterView = () -> _FooterView
    
    typealias MakeOperatorPickerPayload = ([_LastPayment], [_Operator])
    typealias MakeOperatorPicker = (MakeOperatorPickerPayload) -> _OperatorPicker
}

// MARK: - _OperatorPicker

struct _OperatorPickerState: Equatable {
    
    let lastPayments: [_LastPayment]
    let operators: [_Operator]
}

enum _OperatorPickerEvent {
    
    case select(Select)
}

extension _OperatorPickerEvent {
    
    enum Select {
        
        case lastPayment(_LastPayment)
        case `operator`(_Operator)
    }
}

struct _OperatorPicker: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 16) {
                        
                        ForEach(state.lastPayments, content: lastPaymentView)
                    }
                }
                
                ForEach(state.operators, content: operatorView)
                
                factory.makeFooterView()
            }
            .padding(.horizontal)
        }
    }
    
    private func lastPaymentView(
        lastPayment: _LastPayment
    ) -> some View {
        
        factory.makeLastPaymentView(lastPayment, { event(.select(.lastPayment($0))) })
    }
    
    private func operatorView(
        `operator`: _Operator
    ) -> some View {
        
        factory.makeOperatorView(`operator`, { event(.select(.operator($0))) })
    }
}

extension _OperatorPicker {
    
    typealias State = _OperatorPickerState
    typealias Event = _OperatorPickerEvent
    typealias Config = _OperatorPickerConfig
    typealias Factory = _OperatorPickerFactory
}

struct _OperatorPickerFactory {
    
    let makeFooterView: MakeFooterView
    let makeLastPaymentView: MakeLastPaymentView
    let makeOperatorView: MakeOperatorView
}

extension _OperatorPickerFactory {
    
    typealias MakeFooterView = () -> _FooterView
    typealias MakeLastPaymentView = (_LastPayment, @escaping (_LastPayment) -> Void) -> _LastPaymentView
    typealias MakeOperatorView = (_Operator, @escaping (_Operator) -> Void) -> _OperatorView
}

struct _LastPaymentView: View {
    
    let state: State
    let event: (State) -> Void
    let config: Config
    
    var body: some View {
        
        SimpleButton(
            title: String(describing: state).prefix(5),
            action: { event(state) }
        )
    }
}

extension _LastPaymentView {
    
    typealias State = _LastPayment
    typealias Config = _LastPaymentViewConfig
}

struct _LastPaymentViewConfig: Equatable {}

struct _OperatorView: View {
    
    let state: State
    let event: (State) -> Void
    let config: Config
    
    var body: some View {
        
        SimpleButton(
            title: String(describing: state).prefix(32),
            action: { event(state) }
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension _OperatorView {
    
    typealias State = _Operator
    typealias Config = _OperatorViewConfig
}

struct _OperatorViewConfig: Equatable {}

private struct SimpleButton: View {
    
    let title: Substring
    let action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            
            Text(title).padding(.vertical)
        }
        .buttonStyle(.plain)
    }
}

struct _OperatorPickerConfig: Equatable {}

enum _FooterViewEvent {
    
    case addCompany
    case payByInstructions
}

struct _FooterView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            if state {
                Text("Нет компании в списке?")
                    .bold()
                secondary("Воспользуйтесь другими способами оплаты")
            } else {
                Image(systemName: "magnifyingglass.circle.fill")
                    .imageScale(.large)
                    .font(.largeTitle)
                    .foregroundColor(.secondary.opacity(0.5))
                secondary("Что-то пошло не так.\nПопробуйте позже или воспользуйтесь другим способом оплаты.")
            }
            
            Button("Pay by Instructions", action: { event(.payByInstructions) })
            
            if state {
                Button("Add Company", action: { event(.addCompany) })
                secondary("Сообщите нам, и мы подключим новую организацию")
            }
        }
    }
    
    private func secondary(_ text: String) -> some View {
        
        Text(text)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}

extension _FooterView {
    
    typealias State = Bool
    typealias Event = _FooterViewEvent
    typealias Config = _FooterViewConfig
}

struct _FooterViewConfig: Equatable {}

// MARK: - _Composed

struct _Composed: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        _UtilityPrepaymentPicker(
            state: state,
            event: event,
            config: config,
            factory: .init(
                makeFooterView: makeFooterView(.error),
                makeOperatorPicker: makeOperatorPicker
            )
        )
    }
    
    private func makeFooterView(
        _ mode: FooterViewMode
    ) -> () -> _FooterView {
        
        return {
            
            _FooterView(
                state: mode.isExpanded,
                event: footerEvent,
                config: config.footer
            )
        }
    }
    
    private enum FooterViewMode {
        
        case error, regular
        
        var isExpanded: Bool { self == .regular }
    }
    
    private func footerEvent(
        _ footerEvent: _FooterViewEvent
    ) {
        switch footerEvent {
        case .addCompany:
            event(.complete(.addCompany))
            
        case .payByInstructions:
            event(.complete(.payByInstructions))
        }
    }
    
    private func makeOperatorPicker(
        _ payload: (lastPayments: [_LastPayment], operators: [_Operator])
    ) -> _OperatorPicker {
        
        _OperatorPicker(
            state: .init(
                lastPayments: payload.lastPayments,
                operators: payload.operators
            ),
            event: operatorPickerEvent,
            config: config.operatorPicker,
            factory: .init(
                makeFooterView: makeFooterView(.regular),
                makeLastPaymentView: makeLastPaymentView,
                makeOperatorView: makeOperatorView
            )
        )
    }
    
    private func operatorPickerEvent(
        _ operatorPickerEvent: _OperatorPickerEvent
    ) {
        switch operatorPickerEvent {
        case let .select(.lastPayment(lastPayment)):
            event(.complete(.select(.lastPayment(lastPayment))))
            
        case let .select(.operator(`operator`)):
            event(.complete(.select(.operator(`operator`))))
        }
    }
    
    private func makeLastPaymentView(
        state: _LastPayment,
        event: @escaping (_LastPayment) -> ()
    ) -> _LastPaymentView {
        
        .init(state: state, event: event, config: config.lastPayment)
    }
    
    private func makeOperatorView(
        state: _Operator,
        event: @escaping (_Operator) -> ()
    ) -> _OperatorView {
        
        .init(state: state, event: event, config: config.operator)
    }
}

extension _Composed {
    
    typealias State = _UtilityPrepaymentPicker.State
    typealias Event = _UtilityPrepaymentPicker.Event
    typealias Config = _UtilityPrepaymentPicker.Config
}

// MARK: - Preview

struct _ComposedStateWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(initialState: _Composed.State) {
        
        let reducer = _UtilityPrepaymentPickerReducer()
        let effectHandler = _UtilityPrepaymentPickerEffectHandler()
        let viewModel = ViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .main
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        _Composed(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .preview
        )
    }
    
    typealias ViewModel = RxViewModel<_Composed.State, _UtilityPrepaymentPickerEvent, _UtilityPrepaymentPickerEffect>
}

#Preview {
    _ComposedStateWrapperView(initialState: .preview)
}

#Preview {
    _ComposedStateWrapperView(initialState: nil)
}

#Preview {
    _OperatorPicker(
        state: .init(lastPayments: .preview, operators: .preview),
        event: { print($0) },
        config: .preview,
        factory: .preview(footerState: true)
    )
}

#Preview {
    _OperatorPicker(
        state: .init(lastPayments: [], operators: .preview),
        event: { print($0) },
        config: .preview,
        factory: .preview(footerState: true)
    )
}

#Preview {
    _OperatorPicker(
        state: .init(lastPayments: [], operators: []),
        event: { print($0) },
        config: .preview,
        factory: .preview(footerState: false)
    )
}

#Preview {
    _FooterView(
        state: true,
        event: { print($0) },
        config: .preview
    )
}

#Preview {
    _FooterView(
        state: false,
        event: { print($0) },
        config: .preview
    )
}

// MARK: - Preview Content

extension _OperatorPickerFactory {
    
    static func preview(
        footerState: Bool
    ) -> Self {
        
        .init(
            makeFooterView: { .init(state: footerState, event: { _ in }, config: .preview) },
            makeLastPaymentView: { .init(state: $0, event: $1, config: .preview) },
            makeOperatorView: { .init(state: $0, event: $1, config: .preview) }
        )
    }
}

extension _LastPaymentViewConfig {
    
    static let preview: Self = .init()
}

extension _OperatorViewConfig {
    
    static let preview: Self = .init()
}

extension _UtilityPrepaymentPickerConfig {
    
    static let preview: Self = .init(
        operatorPicker: .preview,
        footer: .preview,
        lastPayment: .preview,
        operator: .preview
    )
}

extension _OperatorPickerConfig {
    
    static let preview: Self = .init()
}

extension _FooterViewConfig {
    
    static let preview: Self = .init()
}

extension _UtilityPrepaymentPickerState {
    
    static let preview: Self = .init(
        lastPayments: .preview,
        operators: .preview
    )
}

extension Array where Element == _LastPayment {
    
    static var preview: Self {
        
        (0..<10).map { _ in
            
            return  .init(id: UUID().uuidString)
        }
    }
}

extension Array where Element == _Operator {
    
    static var preview: Self {
        
        (0..<30).map { _ in
            
            return  .init(id: UUID().uuidString)
        }
    }
}
