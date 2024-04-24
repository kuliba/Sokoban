//
//  _exploring.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import Combine
import RxViewModel
import SwiftUI
import UIPrimitives

struct _LastPayment<Icon>: Identifiable {
    
    let id: String
    let icon: Icon
}

extension _LastPayment: Equatable where Icon: Equatable {}

struct _Operator<Icon>: Identifiable {
    
    let id: String
    let icon: Icon
}

extension _Operator: Equatable where Icon: Equatable {}

struct _UtilityService<Icon>: Identifiable {
    
    let id: String
    let icon: Icon
}

extension _UtilityService: Equatable where Icon: Equatable {}

// MARK: - _UtilityPrepaymentPicker

struct _UtilityPrepaymentPickerState<Icon> {
    
    let lastPayments: [_LastPayment<Icon>]
    let operators: [_Operator<Icon>] // non empty
}

extension _UtilityPrepaymentPickerState: Equatable where Icon: Equatable {}

enum _UtilityPrepaymentPickerEvent<Icon> {
    
    case complete(Complete)
}

extension _UtilityPrepaymentPickerEvent {
    
    enum Complete {
        
        case addCompany
        case payByInstructions
        case select(Select)
    }
}

extension _UtilityPrepaymentPickerEvent.Complete {
    
    enum Select {
        
        case lastPayment(_LastPayment<Icon>)
        case `operator`(_Operator<Icon>)
    }
}

extension _UtilityPrepaymentPickerEvent: Equatable where Icon: Equatable {}
extension _UtilityPrepaymentPickerEvent.Complete: Equatable where Icon: Equatable {}
extension _UtilityPrepaymentPickerEvent.Complete.Select: Equatable where Icon: Equatable {}

enum _UtilityPrepaymentPickerEffect<Icon> {}

extension _UtilityPrepaymentPickerEffect: Equatable where Icon: Equatable {}

final class _UtilityPrepaymentPickerReducer<Icon> {}

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
    
    typealias State = _UtilityPrepaymentPickerState<Icon>?
    typealias Event = _UtilityPrepaymentPickerEvent<Icon>
    typealias Effect = _UtilityPrepaymentPickerEffect<Icon>
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
        
        let state = state
        let effect: Effect?
        
        switch event {
        case let .lastPayment(_):
            fatalError()
            
        case let .operator(_):
            fatalError()
        }
        
        return (state, effect)
    }
}

final class _UtilityPrepaymentPickerEffectHandler<Icon> {}

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
    
    typealias Event = _UtilityPrepaymentPickerEvent<Icon>
    typealias Effect = _UtilityPrepaymentPickerEffect<Icon>
}

struct _UtilityPrepaymentPicker<Icon>: View {
    
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
    
    typealias State = _UtilityPrepaymentPickerState<Icon>?
    typealias Event = _UtilityPrepaymentPickerEvent<Icon>
    typealias Config = _UtilityPrepaymentPickerConfig
    typealias Factory = _UtilityPrepaymentPickerFactory<Icon>
}

struct _UtilityPrepaymentPickerConfig: Equatable {
    
    let operatorPicker: _OperatorPickerConfig
    let footer: _FooterViewConfig
    let lastPayment: _LastPaymentViewConfig
    let `operator`: _OperatorViewConfig
}

struct _UtilityPrepaymentPickerFactory<Icon> {
    
    let makeFooterView: MakeFooterView
    let makeOperatorPicker: MakeOperatorPicker
}

extension _UtilityPrepaymentPickerFactory {
    
    typealias MakeFooterView = () -> _FooterView
    
    typealias LastPayment = _LastPayment<Icon>
    typealias Operator = _Operator<Icon>
    typealias MakeOperatorPickerPayload = ([LastPayment], [Operator])
    typealias MakeOperatorPicker = (MakeOperatorPickerPayload) -> _OperatorPicker<Icon>
}

// MARK: - _OperatorPicker

struct _OperatorPickerState<Icon> {
    
    let lastPayments: [LastPayment]
    let operators: [Operator]
}

extension _OperatorPickerState {
    
    typealias LastPayment = _LastPayment<Icon>
    typealias Operator = _Operator<Icon>
}

extension _OperatorPickerState: Equatable where Icon: Equatable {}

enum _OperatorPickerEvent<Icon> {
    
    case select(Select)
}

extension _OperatorPickerEvent {
    
    enum Select {
        
        case lastPayment(LastPayment)
        case `operator`(Operator)
    }
}

extension _OperatorPickerEvent.Select {
    
    typealias LastPayment = _LastPayment<Icon>
    typealias Operator = _Operator<Icon>
}

extension _OperatorPickerEvent: Equatable where Icon: Equatable {}
extension _OperatorPickerEvent.Select: Equatable where Icon: Equatable {}

struct _OperatorPicker<Icon>: View {
    
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
        lastPayment: LastPayment
    ) -> some View {
        
        factory.makeLastPaymentView(lastPayment, { event(.select(.lastPayment($0))) })
    }
    
    private func operatorView(
        `operator`: Operator
    ) -> some View {
        
        factory.makeOperatorView(`operator`, { event(.select(.operator($0))) })
    }
}

extension _OperatorPicker {

    typealias LastPayment = _LastPayment<Icon>
    typealias Operator = _Operator<Icon>

    typealias State = _OperatorPickerState<Icon>
    typealias Event = _OperatorPickerEvent<Icon>
    typealias Config = _OperatorPickerConfig
    typealias Factory = _OperatorPickerFactory<Icon>
}

struct _OperatorPickerFactory<Icon> {
    
    let makeFooterView: MakeFooterView
    let makeLastPaymentView: MakeLastPaymentView
    let makeOperatorView: MakeOperatorView
}

extension _OperatorPickerFactory {
    
    typealias LastPayment = _LastPayment<Icon>
    typealias Operator = _Operator<Icon>

    typealias MakeFooterView = () -> _FooterView
    typealias AsyncImage = UIPrimitives.AsyncImage
    typealias MakeLastPaymentView = (LastPayment, @escaping (LastPayment) -> Void) -> _LastPaymentView<Icon, AsyncImage>
    typealias MakeOperatorView = (Operator, @escaping (Operator) -> Void) -> _OperatorView<Icon, AsyncImage>
}

struct _LastPaymentView<Icon, IconView>: View
where IconView: View {
    
    let state: State
    let event: (State) -> Void
    let config: Config
    let iconView: (Icon) -> IconView
    
    var body: some View {
        
        HStack {
         
            iconView(state.icon)
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            SimpleButton(
                title: String(describing: state).prefix(5),
                action: { event(state) }
            )
        }
    }
}

extension _LastPaymentView {
    
    typealias State = _LastPayment<Icon>
    typealias Config = _LastPaymentViewConfig
}

struct _LastPaymentViewConfig: Equatable {}

struct _OperatorView<Icon, IconView>: View
where IconView: View {
    
    let state: State
    let event: (State) -> Void
    let config: Config
    let iconView: (Icon) -> IconView
    
    var body: some View {
        
        HStack {
            
            iconView(state.icon)
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            SimpleButton(
                title: String(describing: state).prefix(32),
                action: { event(state) }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension _OperatorView {
    
    typealias State = _Operator<Icon>
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

struct _Composed<Icon>: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let imageSubject: CurrentValueSubject<Image, Never>
    
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
        _ payload: (lastPayments: [LastPayment], operators: [Operator])
    ) -> _OperatorPicker<Icon> {
        
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
        _ operatorPickerEvent: _OperatorPickerEvent<Icon>
    ) {
        switch operatorPickerEvent {
        case let .select(.lastPayment(lastPayment)):
            event(.complete(.select(.lastPayment(lastPayment))))
            
        case let .select(.operator(`operator`)):
            event(.complete(.select(.operator(`operator`))))
        }
    }
    
    private func makeLastPaymentView(
        state: LastPayment,
        event: @escaping (LastPayment) -> ()
    ) -> _LastPaymentView<Icon, AsyncImage> {
        
        .init(
            state: state,
            event: event,
            config: config.lastPayment,
            iconView: iconView
        )
    }
    
    private func makeOperatorView(
        state: Operator,
        event: @escaping (Operator) -> ()
    ) -> _OperatorView<Icon, AsyncImage> {
        
        .init(
            state: state,
            event: event,
            config: config.operator,
            iconView: iconView
        )
    }
    
    private func iconView(
        icon: Icon
    ) -> AsyncImage {
        
        .init(
            image: imageSubject.value,
            publisher: imageSubject.eraseToAnyPublisher()
        )
    }
}

extension _Composed {
    
    typealias LastPayment = _LastPayment<Icon>
    typealias Operator = _Operator<Icon>

    typealias AsyncImage = UIPrimitives.AsyncImage
    
    typealias State = _UtilityPrepaymentPicker<Icon>.State
    typealias Event = _UtilityPrepaymentPicker<Icon>.Event
    typealias Config = _UtilityPrepaymentPicker<Icon>.Config
}

// MARK: - Preview

struct _ComposedStateWrapperView<Icon>: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(initialState: _Composed<Icon>.State) {
        
        let reducer = _UtilityPrepaymentPickerReducer<Icon>()
        let effectHandler = _UtilityPrepaymentPickerEffectHandler<Icon>()
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
            config: .preview,
            imageSubject: .init(.init(systemName: "car"))
        )
    }
    
    typealias ViewModel = RxViewModel<_Composed<Icon>.State, _UtilityPrepaymentPickerEvent<Icon>, _UtilityPrepaymentPickerEffect<Icon>>
}

#Preview {
    _ComposedStateWrapperView(initialState: .preview)
}

#Preview {
    _ComposedStateWrapperView<String>(initialState: nil)
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
    _OperatorPicker<String>(
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
            makeLastPaymentView: { .init(state: $0, event: $1, config: .preview, iconView: iconView) },
            makeOperatorView: { .init(state: $0, event: $1, config: .preview, iconView: iconView) }
        )
    }
    
    private static func iconView(icon: Icon) -> AsyncImage {
        
        .init(
            image: imageSubject.value,
            publisher: imageSubject.eraseToAnyPublisher()
        )
    }
    
    private static var imageSubject: CurrentValueSubject<Image, Never> {
        
        .init(.init(systemName: "car"))
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

extension _UtilityPrepaymentPickerState where Icon == String {
    
    static var preview: Self {
        
        .init(
            lastPayments: .preview,
            operators: .preview
        )
    }
}

extension Array where Element == _LastPayment<String> {
    
    static var preview: Self {
        
        (0..<10).map { _ in
            
            return  .init(id: UUID().uuidString, icon: UUID().uuidString)
        }
    }
}

extension Array where Element == _Operator<String> {
    
    static var preview: Self {
        
        (0..<30).map { _ in
            
            return  .init(id: UUID().uuidString, icon: UUID().uuidString)
        }
    }
}
