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
            map: { $0 },
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
    
#warning("change second Payment to a type with CachedModelsState as property")
    typealias ViewModel = RxMappingViewModel<Payment, Payment, PaymentEvent, PaymentEffect>
}

private extension PaymentWrapperView {
    
    func list(
        fields: [Field],
        update: @escaping (Field.Value, Field) -> Void
    ) -> some View {
        
        List {
            
            ForEach(fields) { fieldView(field: $0, update: update) }
        }
        .listStyle(.plain)
    }
    
    func fieldView(
        field: Field,
        update: @escaping (Field.Value, Field) -> Void
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(field.title)
                .foregroundColor(.secondary)
                .font(.caption.bold())
            
            TextField(
                field.title,
                text: .init(
                    get: { field.value },
                    set: { update($0, field) }
                )
            )
        }
    }
    
    func update(
        value: Field.Value,
        of field: Field
    ) {
        viewModel.event(.set(value: value, forID: field.id))
    }
    
    typealias Field = Payment.Field
    
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
            let newField = Field(id: UUID().uuidString, title: "New field", value: "")
            viewModel.event(.add(newField))
        } label: {
            Label(("Add field"), systemImage: "plus")
        }
    }
}

extension Payment: CustomStringConvertible {
    
    var description: String {
        
        return fields
            .map { "\($0.id.suffix(6)): \"\($0.value)\"" }
            .joined(separator: "\n")
    }
}

//#Preview {
//    PaymentWrapperView(viewModel: <#PaymentWrapperView.ViewModel#>)
//}
