//
//  SimpleOTPWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import SwiftUI

struct SimpleOTPWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        SimpleOTPView(state: viewModel.state, event: viewModel.event(_:))
    }
}

extension SimpleOTPWrapperView {
    
    typealias ViewModel = AnywayElementModel.Widget.OTPViewModel
}

struct SimpleOTPView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        HStack {
            
            VStack(alignment: .leading) {
                
                Text("OTP")
                Text(state.value.map { "\($0)" } ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextField(
                "Введите код",
                text: .init(
                    get: { state.value.map { "\($0)" } ?? "" },
                    set: { event(.input($0)) }
                )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.gray.opacity(0.1))
        )
    }
}

extension SimpleOTPView {
    
    typealias State = AnywayElementModel.Widget.OTPState
    typealias Event = AnywayElementModel.Widget.OTPEvent
}
