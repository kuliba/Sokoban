//
//  MultiOperatorView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.06.2023.
//

import SwiftUI

// MARK: - ViewModel

extension MultiOperatorView {
    
    final class ViewModel: ObservableObject {
        
        @Published private(set) var selection: String?
        
        let paymentsGroupViewModel: PaymentsGroupViewModel
        
        init() {
            
            paymentsGroupViewModel = .init(items: .avtodor)
            
            paymentsGroupViewModel.items.first?
                .$value
                .map(\.current)
                .receive(on: DispatchQueue.main)
                .assign(to: &$selection)
        }
    }
}

// MARK: - Helpers

private extension Array where Element == PaymentsParameterViewModel {
    
    static var avtodor: Self {
        
        return [PaymentsParameterViewModel.avtodor()]
            .compactMap { $0 }
    }
}

private extension PaymentsParameterViewModel {
    
    static func avtodor() -> PaymentsParameterViewModel? {
        
        return try? PaymentSelectDropDownView.ViewModel(
            id: "avtodor",
            value: Purefs.avtodorContract,
            title: "Способ оплаты",
            options: .avtodor
        )
    }
}

private extension PaymentSelectDropDownView.ViewModel {
    
    convenience init(
        id: String,
        value: String,
        title: String,
        options: [Payments.ParameterSelectDropDownList.Option]
    ) throws {
        let parameterSelect: Payments.ParameterSelectDropDownList = .init(
            .init(id: id, value: value),
            title: title,
            options: options
        )
        
        try self.init(with: parameterSelect)
    }
}

extension Array where Element == Payments.ParameterSelectDropDownList.Option {
    
    static let avtodor: Self = [
        .init(
            id: Purefs.avtodorContract,
            name: "По договору",
            icon: .name("ic24FileHash")
        ),
        .init(
            id: Purefs.avtodorTransponder,
            name: "По транспондеру",
            icon: .name("ic24Hash")
        )
    ]
}

// MARK: - View

struct MultiOperatorView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let action: (String) -> Void
    
    init(
        viewModel: ViewModel,
        action: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self.action = action
    }
    
    var body: some View {
        
        VStack {
            
            PaymentsGroupView(viewModel: viewModel.paymentsGroupViewModel)
            
            Spacer()
            
            Text(viewModel.selection ?? "n/a")
            
            Spacer()
            
            Button {
                
                viewModel.selection.map(action)
                
            } label: {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.red)
                    
                    Text("Continue")
                        .foregroundColor(.white)
                }
            }
            .disabled(viewModel.selection == nil)
            .frame(height: 56)
            .padding()
        }
    }
}

// MARK: - Preview

struct MultiOperatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MultiOperatorView(viewModel: .init(), action: { _ in })
    }
}
