//
//  PaymentWrapperView.swift
//  CachedModelsStatePreview
//
//  Created by Igor Malyarov on 04.06.2024.
//

import SwiftUI

struct PaymentWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init() {
#warning("add observing to viewModel - i.e. wrap again!!")
        let initialState = Payment(fields: [])
        let reducer = PaymentReducer()
        let source = PaymentViewModel(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        let viewModel = ViewModel(
            source: source,
            map: { $0 }
        )
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        VStack {
            
            List {
                
                ForEach(viewModel.state.fields, content: fieldView)
            }
            
            footer()
        }
    }
}

extension PaymentWrapperView {
    
#warning("change second Payment to a type with CachedModelsState as property")
    typealias ViewModel = RxMappingViewModel<Payment, Payment, PaymentEvent, PaymentEffect>
}

private extension PaymentWrapperView {
    
    func fieldView(
        field: Field
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(field.title)
                .foregroundColor(.secondary)
                .font(.caption.bold())
            
            TextField(
                field.title,
                text: .init(
                    get: { field.value },
                    set: { viewModel.event(.set(value: $0, forID: field.id)) }
                )
            )
        }
    }
    
    typealias Field = Payment.Field
    
    func footer() -> some View {
        
        VStack {
            
            Text(viewModel.state.description)
                .foregroundColor(.secondary)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack {
                
                Group {
                    
                    Text("fields count: \(viewModel.state.fields.count)")
                        .foregroundColor(.secondary)
                        .font(.footnote.bold())
                    
                    Button("Add field") {
                        
                        viewModel.event(.add(.init(id: UUID().uuidString, title: "New field", value: "")))
                    }
                }
                .frame(maxWidth: .infinity)
            }
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
