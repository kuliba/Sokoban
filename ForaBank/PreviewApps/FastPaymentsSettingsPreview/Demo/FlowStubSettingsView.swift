//
//  FlowStubSettingsView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import SwiftUI

struct FlowStubSettingsView: View {
    
    @State private var getProducts: GetProducts?
    
    private let commit: (FlowStub) -> Void
    
    init(
        flowStub: FlowStub?,
        commit: @escaping (FlowStub) -> Void
    ) {
        self.commit = commit
        self.getProducts = flowStub.map { .init(flowStub: $0) }
    }
    
    private var flowStub: FlowStub? {
        
        nil
    }
    
    var body: some View {
        
        Form {
            
            getProductsPicker()
            
        }
        .overlay(alignment: .bottom, content: applyButton)
    }
    
    private func getProductsPicker() -> some View {
        
        HStack {
            Text("Select products")
            
            Picker("Select products", selection: $getProducts) {
                
                ForEach(GetProducts.allCases) {
                    
                    Text($0.rawValue)
                        .tag(Optional($0))
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func applyButton() -> some View {
        
        Button {
            
        } label: {
            Text("Apply")
                .font(.headline)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .buttonStyle(.borderedProminent)
        .disabled(flowStub == nil)
    }
}

private extension FlowStubSettingsView {
    
    enum GetProducts: String, CaseIterable, Identifiable {
        
        case empty, preview
        
        var id: Self { self }
    }
}

private extension FlowStubSettingsView.GetProducts {
    
    init(flowStub: FlowStub) {
        
        if flowStub.getProducts.isEmpty {
            self = .empty
        } else {
            self = .preview
        }
    }
}

struct FlowStubSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        flowStubSettingsView(nil)
        flowStubSettingsView(.preview)
    }
    
    private static func flowStubSettingsView(
        _ flowStub: FlowStub?
    ) -> some View {
        
        FlowStubSettingsView(flowStub: flowStub, commit: { _ in })
    }
}

extension FlowStub {
    
    static let preview: Self = .init(
        getProducts: .preview,
        createContract:  .success(.active),
        getSettings: .contracted(.preview()),
        prepareSetBankDefault: .success(()),
        updateContract: .success(.active),
        updateProduct: .success(())
    )
}
