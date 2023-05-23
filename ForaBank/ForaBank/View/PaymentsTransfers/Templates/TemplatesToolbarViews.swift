//
//  TemplatesToolbarViews.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 24.04.2023.
//

import SwiftUI

//MARK: - ToolbarViews

extension TemplatesListView {
    
    struct RegularNavBarView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.RegularNavBarViewModel
        @Environment(\.mainWindowSize) var mainWindowSize
        
        var body: some View {
            
            HStack {
                
                Button(action: viewModel.backButton.action,
                       label: { viewModel.backButton.icon })
                
                if #available(iOS 15.0, *) {
                    Spacer()
                } else {
                    Spacer(minLength: mainWindowSize.width - 108)
                }
                
                Button(action: viewModel.searchButton.action,
                       label: {
                    viewModel.searchButton.icon
                        .opacity(viewModel.isSearchButtonDisable ? 0.4 : 1.0)
                })
                .disabled(viewModel.isSearchButtonDisable)
                
                Menu {
                    
                    ForEach(viewModel.menuList) { item in
                        
                        Button(action: item.action) {
                            Label(item.title, image: item.textImage)
                        }
                    }
                } label: {
                    
                    viewModel.menuImage
                        .opacity(viewModel.isMenuDisable ? 0.4 : 1.0)
                }
                .disabled(viewModel.isMenuDisable)
            }
            .foregroundColor(.textSecondary)
            .overlay13 {
                
                Text(viewModel.title)
                    .font(.textH3M18240())
                    .frame(maxWidth: .infinity)
            }
            
        }
    }
    
    struct TwoButtonsNavBarView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.TwoButtonsNavBarViewModel
        @Environment(\.mainWindowSize) var mainWindowSize
        
        var body: some View {
            
            HStack {
                
                Button(action: viewModel.leadingButton.action,
                       label: { viewModel.leadingButton.icon })
                
                if #available(iOS 15.0, *) {
                    Spacer()
                } else {
                    Spacer(minLength: mainWindowSize.width - 108)
                }
                
                Button(action: viewModel.trailingButton.action,
                       label: { viewModel.trailingButton.icon })
            }
            .foregroundColor(.textSecondary)
            .overlay13 {
                
                Text(viewModel.title)
                    .font(.textH3M18240())
                    .frame(maxWidth: .infinity)
            }
            
        }
    }
    
    struct SearchTextField: UIViewRepresentable {
        
        @Binding var text: String
        
        class Coordinator: NSObject, UITextFieldDelegate {
            
            @Binding var text: String
            var didBecomeFirstResponder = false
            
            init(text: Binding<String>) {
                self._text = text
            }
            
            func textFieldDidChangeSelection(_ textField: UITextField) {
                self.text = textField.text ?? ""
            }
            
        }
        
        func makeUIView(context: Context) -> UITextField {
            let textField = UITextField(frame: .zero)
            
            textField.placeholder = "Название шаблона"
            textField.delegate = context.coordinator
            return textField
        }
        
        func updateUIView(_ uiView: UITextField, context: Context) {
            
            uiView.text = text
            if !context.coordinator.didBecomeFirstResponder  {
                uiView.becomeFirstResponder()
                context.coordinator.didBecomeFirstResponder = true
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text)
        }
        
    }
    
    struct SearchNavBarView: View {
        
        @ObservedObject var viewModel: TemplatesListViewModel.SearchNavBarViewModel
        @Environment(\.mainWindowSize) var mainWindowSize
        
        var body: some View {
            
            HStack {
                
                viewModel.trailIcon
                
                TemplatesListView.SearchTextField
                    .init(text: $viewModel.searchText)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: mainWindowSize.width - 198)
                
                if let clearButton = viewModel.clearButton {
                    
                    Button(action: clearButton.action, label: { clearButton.icon })
                        .frame(width: 32)
                    
                } else {
                    
                    Color(.clear).frame(width: 32)
                }
                
                Button(viewModel.closeButton.title, action: viewModel.closeButton.action)
            }
            
        }
    }
    
}

struct TemplatesNavBar_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            NavigationView {
                
                Text("Delete State")
                    .environment(\.mainWindowSize, CGSize(width: 414, height: 800))
                    .toolbar {
                        
                        ToolbarItem(placement: .principal) {
                            
                            TemplatesListView.TwoButtonsNavBarView
                                .init(viewModel: .init(leadingButton: .init(title: "",
                                                                         icon: .ic24ChevronLeft,
                                                                         action: {}),
                                                       trailingButton: .init(title: "",
                                                                          icon: .ic24Close,
                                                                             action: {}),
                                                       title: "Выбрать шаблоны"))
                        }
                    }
            }
           
        }
    }
}
