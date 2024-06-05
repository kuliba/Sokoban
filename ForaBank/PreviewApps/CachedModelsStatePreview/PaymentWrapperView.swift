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
        
        let initialState = Payment(fields: [])
        let reducer = PaymentReducer()
        let source = PaymentViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )

        let viewModel = ViewModel(
            source: source,
            map: { field in
                
                let reducer = InputReducer()
                let effectHandler = InputEffectHandler()
                
                return .init(
                    initialState: .init(
                        title: field.title,
                        text: field.value
                    ),
                    reduce: reducer.reduce(_:_:),
                    handleEffect: effectHandler.handleEffect(_:_:),
                    observe: {
                    
                        source.event(.set(value: $0.text, forID: field.id))
                    }
                )
            },
            observe: { _, last in print("payment:", last) }
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack {
            
            list(fields: viewModel.state.fields, update: update(value:of:))
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
        fields: [Field],
        update: @escaping (String, Field) -> Void
    ) -> some View {
        
        List {
            
            ForEach(fields) { fieldView(field: $0, update: update) }
        }
        .listStyle(.plain)
    }
    
    func fieldView(
        field: Field,
        update: @escaping (String, Field) -> Void
    ) -> some View {
        
        InputWrapperView(viewModel: field.model)
    }
    
    func update(
        value: String,
        of field: Field
    ) {
        viewModel.event(.set(value: value, forID: field.id))
    }
    
    typealias ID = CachedPayment.Field.ID
    typealias Field = CachedPayment.IdentifiedField
    
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
    }
    
    func fieldsCountView() -> some View {
        
        Text("fields count: \(viewModel.state.fields.count)")
            .foregroundColor(.secondary)
            .font(.footnote.bold())
    }
    
    func addFieldButton() -> some View {
        
        Button {
            viewModel.event(.add(makeNewField()))
        } label: {
            Label("Add field", systemImage: "plus")
        }
    }
    
    private func makeNewField() -> Payment.Field {
     
        return .init(id: UUID().uuidString, title: "New field", value: "")
    }
}

extension Payment: CustomStringConvertible {
    
    var description: String {
        
        return fields
            .map { "\($0.id.suffix(6)): \"\($0.value)\"" }
            .joined(separator: "\n")
    }
}

extension CachedPayment: CustomStringConvertible {
    
    var description: String {
        
        return fields
            .map { "\($0.id.suffix(6)): \"\($0.model.state.text)\"" }
            .joined(separator: "\n")
    }
}

//#Preview {
//    PaymentWrapperView(viewModel: <#PaymentWrapperView.ViewModel#>)
//}
