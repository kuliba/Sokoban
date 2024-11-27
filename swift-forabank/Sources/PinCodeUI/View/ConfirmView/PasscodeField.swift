//
//  PasscodeField.swift
//  
//
//  Created by Andryusina Nataly on 25.07.2023.
//

import SwiftUI

public struct PasscodeField: View {
    
    @ObservedObject public var viewModel: ConfirmViewModel
    
    public init(viewModel: ConfirmViewModel) {
        
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack(spacing: 5) {
            
            ZStack {
                
                PinDots
                BackgroundField
            }
        }
        .padding(.top, 40)
        .autofocus()
    }
    
    private var PinDots: some View {
        
        HStack(spacing: 16) {
            
            ForEach(0..<viewModel.maxDigits) { index in
                
                DigitView(
                    value: viewModel.getDigit(at: index),
                    config: .defaultValue
                )
            }
        }
    }
    
    private var BackgroundField: some View {
        
        let binding = Binding<String>(
            get: { viewModel.otp.rawValue },
            set: { newValue in
                
                viewModel.otp = .init(newValue)
                viewModel.submitOtp()
            }
        )
        
        return TextField("", text: binding, onCommit: viewModel.submitOtp)
            .textContentType(.oneTimeCode)
            .accentColor(.clear)
            .foregroundColor(.clear)
            .keyboardType(.numberPad)
            .disabled(viewModel.isDisabled)
    }
}

private struct FocusableUIView: UIViewRepresentable {
    
    var isFirstResponder: Bool = false

    class Coordinator: NSObject {
        
        var didBecomeFirstResponder = false
    }

    func makeUIView(
        context: UIViewRepresentableContext<FocusableUIView>
    ) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func makeCoordinator() -> FocusableUIView.Coordinator {
        
        return Coordinator()
    }

    func updateUIView(
        _ uiView: UIView,
        context: UIViewRepresentableContext<FocusableUIView>
    ) {
        
        guard uiView.window != nil, isFirstResponder, !context.coordinator.didBecomeFirstResponder else {
            return
        }

        var foundRepsonder: UIView?
        var currentSuperview: UIView? = uiView
        repeat {
            foundRepsonder = currentSuperview?.subviewFirstPossibleResponder
            currentSuperview = currentSuperview?.superview
        } while foundRepsonder == nil && currentSuperview != nil

        guard let responder = foundRepsonder else {
            return
        }

        DispatchQueue.main.async {
            responder.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

private extension UIView {
    
    var subviewFirstPossibleResponder: UIView? {
        
        guard !canBecomeFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.subviewFirstPossibleResponder {
                return firstResponder
            }
        }

        return nil
    }
}

private extension View {
    
    @ViewBuilder
    func autofocus() -> some View {
        
        if #available(iOS 15, *) {
            
            modifier(AutofocusedViewModifiers.Modern())
        } else {
            
            modifier(AutofocusedViewModifiers.Legacy())
        }
    }
}

private enum AutofocusedViewModifiers {
    
    struct Legacy: ViewModifier {
        
        @State private var isFocused = false
        
        func body(content: Content) -> some View {
            
            content
                .background(FocusableUIView(isFirstResponder: isFocused))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isFocused = true
                    }
                }
        }
    }

    struct Modern: ViewModifier {
        
        @FocusState private var isFocused: Bool
        
        func body(content: Content) -> some View {
            
            content
                .focused($isFocused)
                .onAppear {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isFocused = true
                    }
                }
        }
    }
}

//MARK: - Preview Content

private extension DigitView.Config {
    
    static let defaultValue: Self = .init(
        foregroundColor: Color(red: 0.6, green: 0.6, blue: 0.6),
        font: Font.custom("Inter", size: 32)
            .weight(.bold),
        filColor: .grayMedium
    )
}

private extension Color {
    
    static let grayMedium = Color(red: 0.83, green: 0.83, blue: 0.83)
}

