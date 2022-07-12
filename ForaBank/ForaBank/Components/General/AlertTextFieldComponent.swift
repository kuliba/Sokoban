//
//  AlertTextFieldComponent.swift
//  ForaBank
//
//  Created by Mikhail on 05.07.2022.
//

import SwiftUI
import Combine

extension AlertTextFieldView {
    
    class ViewModel: Identifiable, ObservableObject {

        let id = UUID()
        let title: String
        let message: String?
        let maxLength: Int?
        var text: String?
        let primary: ButtonViewModel
        var secondary: ButtonViewModel? = nil
        
        var binding: AnyCancellable?
        
        internal init(title: String, message: String?, text: String? = nil, maxLength: Int? = nil, primary: AlertTextFieldView.ViewModel.ButtonViewModel, secondary: AlertTextFieldView.ViewModel.ButtonViewModel? = nil) {
            
            self.title = title
            self.message = message
            self.maxLength = maxLength
            self.text = text
            self.primary = primary
            self.secondary = secondary
        }

        struct ButtonViewModel {
            
            let type: Kind
            let title: String
            let action: (String?) -> Void
            
            enum Kind {
                
                case `default`
                case distructive
                case cancel
            }
            
            var style: UIAlertAction.Style {
                
                switch type {
                case .default: return .default
                case .distructive: return .destructive
                case .cancel: return .cancel
                }
            }
        }
    }
}

struct AlertTextFieldView: UIViewControllerRepresentable {
 
    let viewModel: ViewModel

    func makeUIViewController(context: Context) -> UIViewController {

        let controller = UIViewController()
        
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            
            let alertController = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
            alertController.addTextField { textField in

                viewModel.binding = NotificationCenter.default
                    .publisher(for: UITextField.textDidChangeNotification, object: textField)
                    .map { ($0.object as? UITextField)?.text }
                    .assign(to: \.viewModel.text, on: self)
                
                textField.delegate = context.coordinator
            }
            
            if let secondary = viewModel.secondary {
                
                alertController.addAction(.init(title: secondary.title, style: secondary.style, handler: { _ in
                    
                    secondary.action(viewModel.text)
                }))
            }
            
            alertController.addAction(.init(title: viewModel.primary.title, style: viewModel.primary.style, handler: { _ in
                
                viewModel.primary.action(viewModel.text)
            }))

            vc.present(alertController, animated: true)
        })
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        var parentObserver: NSKeyValueObservation?
        
        var viewModel: AlertTextFieldView.ViewModel
            
        init(_ viewModel: AlertTextFieldView.ViewModel) {
            self.viewModel = viewModel
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            
            guard let maxLength = viewModel.maxLength else { return true }
            guard let currentString: NSString = textField.text as? NSString else { return true }
            let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
    }
    
    func makeCoordinator() -> Self.Coordinator { Coordinator(viewModel) }
}

struct AlertTextFieldViewModifier: ViewModifier {
    
    @Binding var viewModel: AlertTextFieldView.ViewModel?
    
    func body(content: Content) -> some View {
        
        if let viewModel = viewModel {
            
            ZStack {
                
                content
                AlertTextFieldView(viewModel: viewModel)
            }
            
        } else {
            
            content
        }
    }
}

extension View {
    
    func textfieldAlert(alert: Binding<AlertTextFieldView.ViewModel?>) -> some View {
        
        modifier(AlertTextFieldViewModifier(viewModel: alert))
    }
}
