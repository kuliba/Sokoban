//
//  PaymentWrapperView.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 04.06.2024.
//

import RxViewModel
import SwiftUI

struct PaymentWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init() {
        
        let initialState = Payment(elements: [])
        let reducer = PaymentReducer()
        let source = PaymentViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        
        let viewModel = ViewModel(
            source: source,
            map: { element in
#warning("extract helper")
                switch element {
                case let .field(field):
                    let reducer = InputReducer()
                    let effectHandler = InputEffectHandler()
                    
                    let inputViewModel = InputViewModel(
                        initialState: .init(
                            title: field.title,
                            text: field.value
                        ),
                        reduce: reducer.reduce(_:_:),
                        handleEffect: effectHandler.handleEffect(_:_:),
                        observe: {
                            
                            source.event(.set(value: $0.text, forID: element.id))
                        }
                    )
                    
                    return .field(inputViewModel)
                    
                case let .param(param):
#warning("replace with different")
                    let reducer = InputReducer()
                    let effectHandler = InputEffectHandler()
                    
                    let inputViewModel = InputViewModel(
                        initialState: .init(
                            title: param.title,
                            text: param.value
                        ),
                        reduce: reducer.reduce(_:_:),
                        handleEffect: effectHandler.handleEffect(_:_:),
                        observe: {
                            
                            source.event(.set(value: $0.text, forID: element.id))
                        }
                    )
                    
                    return .field(inputViewModel)
                }
            },
            observe: { print("payment:\n", $0) }
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack {
            
            list(models: viewModel.state.models)
            footer(description: viewModel.state.description)
        }
        .toolbar(content: toolbar)
    }
}

extension PaymentWrapperView {
    
    typealias ViewModel = ObservingCachedPaymentViewModel
}

private extension PaymentWrapperView {
    
    func list(
        models: [CachedPayment.IdentifiedModels]
    ) -> some View {
        
        List {
            
            ForEach(models) { modelView(model: $0.model) }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func modelView(
        model: CachedPayment.ElementModel
    ) -> some View {
        
        switch model {
        case let .field(field):
            InputWrapperView(viewModel: field)
            
        case let .param(param):
            OtherInputWrapperView(viewModel: param)
        }
    }
    
    @ViewBuilder
    func footer(
        description: String
    ) -> some View {
        
        if #available(iOS 15.0, *) {
            footer(description)
                .background(.ultraThinMaterial)
        } else {
            footer(description)
                .background(Color.gray.opacity(0.1))
        }
    }
    
    @ViewBuilder
    private func footer(
        _ description: String
    ) -> some View {
        
        if !description.isEmpty {
            
            Text(description)
                .foregroundColor(.secondary)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading, content: fieldsCountView)
        ToolbarItem(placement: .topBarTrailing, content: addFieldButton)
        ToolbarItem(placement: .topBarTrailing, content: addParamButton)
    }
    
    func fieldsCountView() -> some View {
        
        Text("fields count: \(viewModel.state.models.count)")
            .foregroundColor(.secondary)
            .font(.footnote.bold())
    }
    
    func addFieldButton() -> some View {
        
        Button {
            viewModel.event(.addField(makeNewField()))
        } label: {
            Label("Add field", systemImage: "plus.circle")
        }
    }
    
    private func makeNewField() -> Payment.Element.Field {
        
        return .init(id: UUID().uuidString, title: "Field", value: "")
    }
    
    func addParamButton() -> some View {
        
        Button {
            viewModel.event(.addParam(makeNewParam()))
        } label: {
            Label("Add param", systemImage: "plus.square")
        }
    }
    
    private func makeNewParam() -> Payment.Element.Param {
        
        return .init(id: UUID().uuidString, title: "Param", subtitle: "subtitle", value: "")
    }
}

extension Payment: CustomStringConvertible {
    
    var description: String {
        
        return elements.map(\.description).joined(separator: "\n")
    }
}

extension Payment.Element: CustomStringConvertible {
    
    var description: String {
        
        switch self {
        case let .field(field):
            return "field: \(field.id.suffix(4)): \"\(field.value)\""
            
        case let .param(param):
            return "param: \(param.id.suffix(4)): \"\(param.value)\""
        }
    }
}

extension CachedPayment: CustomStringConvertible {
    
    var description: String {
        
        return models.map(\.description).joined(separator: "\n")
    }
}

extension CachedPayment.IdentifiedModels: CustomStringConvertible {
    
    var description: String {
        
        "\(id.description): \"\(model.description)\""
    }
}

extension CachedPayment.Element.ID: CustomStringConvertible {
    
    var description: String {
        
        switch self {
        case let .field(id): return "field: \(id.suffix(4))"
        case let .param(id): return "param: \(id.suffix(4))"
        }
    }
}

extension CachedPayment.ElementModel: CustomStringConvertible {
    
    var description: String {
        
        switch self {
        case let .field(field): return "\(field.state.text)"
        case let .param(param): return "\(param.state.text)"
        }
    }
}
//#Preview {
//    PaymentWrapperView(viewModel: <#PaymentWrapperView.ViewModel#>)
//}
