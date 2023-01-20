//
//  QRAccessViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.12.2022.
//

import SwiftUI

extension QRAccessView {
    
    class ViewModel: Identifiable {
        
        var id = UUID()
        let icon: Image
        let title: String
        let content: String
        @Published var clouseButton: ButtonSimpleView.ViewModel
        
        internal init(icon: Image, title: String, content: String, clouseButton: ButtonSimpleView.ViewModel) {
            self.icon = icon
            self.title = title
            self.content = content
            self.clouseButton = clouseButton
        }
        
        convenience init(input: Input, closeAction: @escaping () -> Void) {
            let clouseButton = ButtonSimpleView.ViewModel(title: "Перейти в настройки", style: .red, action: closeAction)
            
            self.init(icon: input.result.2, title: input.result.0,
                      content: input.result.1,
                      clouseButton: clouseButton)
        }
        
        enum Input {
            case photo
            case camera
            
            var result: (String, String, Image) {
                switch self {
                case .photo: return ("Разрешите доступ к фото", "Сможете сканировать файлы/документы с QR-кодом", Image.ic24Image)
                case .camera: return ("Разрешите доступ к камере", "Сможете оплачивать по QR-коду и сканировать карты", Image.ic24Camera)
                }
            }
        }
    }
}

struct QRAccessView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 64) {
            
            VStack(spacing: 24) {
                
                ZStack {
                    
                    Circle()
                        .foregroundColor(.buttonSecondaryDisabled)
                        .frame(width: 64, height: 64)
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.iconBlack)
                }
             
                VStack(spacing: 8) {
                    
                    Text(viewModel.title)
                        .foregroundColor(Color.textSecondary)
                        .font(.textH4M16240())
                    
                    Text(viewModel.content)
                        .foregroundColor(.textPlaceholder)
                        .font(.textBodySR12160())
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 5)
                }
                .padding(.horizontal, 25)
            }
            
            ButtonSimpleView(viewModel: viewModel.clouseButton)
                .frame(height: 56)
            
        }
    }
}

//MARK: - Preview

struct QRAccessViewComponent_Previews: PreviewProvider {
    
    static var clouseButton = ButtonSimpleView.ViewModel(title: "Перейти в настройки", style: .red, action: {})
    
    static var previews: some View {
        
        QRAccessView(viewModel: .init(icon: .ic24AlertCircle,
                                               title: "Разрешите доступ к фото",
                                               content: "Сможете сканировать файлы/документы с QR-кодом",
                                               clouseButton: Self.clouseButton
                              ))
        .previewLayout(.fixed(width: 400, height: 400))
    }
}

