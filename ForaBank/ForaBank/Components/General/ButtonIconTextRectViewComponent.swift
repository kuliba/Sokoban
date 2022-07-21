//
//  ButtonIconTextRectViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 31.05.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ButtonIconTextRectView {
    
    struct ViewModel: Identifiable, Hashable {
       
        let id: String
        let icon: Image
        let title: String
        var isEnabled: Bool = true
        let action: () -> Void
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: ButtonIconTextRectView.ViewModel, rhs: ButtonIconTextRectView.ViewModel) -> Bool {
            return lhs.id == rhs.id && lhs.title == rhs.title && lhs.isEnabled == rhs.isEnabled
        }
    }
}

//MARK: - View

struct ButtonIconTextRectView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        Button(action: viewModel.action) {
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.mainColorsGrayLightest)
                
                HStack(spacing: 12) {
                    
                    viewModel.icon
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.iconBlack)
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                        .foregroundColor(.buttonBlack)
                        .multilineTextAlignment(.leading)
                        
                }
                .padding(.leading, 12)
            }
        }
        .buttonStyle(PushButtonStyle())
        .disabled(viewModel.isEnabled ? false : true)
        .opacity(viewModel.isEnabled ? 1.0 : 0.3)
    }
}

//MARK: - Preview

struct ButtonIconTextRectViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonIconTextRectView(viewModel: .sample)
                .frame(width: 164, height: 48)
                .previewLayout(.fixed(width: 200, height: 100))
            
            ButtonIconTextRectView(viewModel: .sampleDisabled)
                .frame(width: 164, height: 48)
                .previewLayout(.fixed(width: 200, height: 100))
        }
    }
}

extension ButtonIconTextRectView.ViewModel {
    
    static let sample = ButtonIconTextRectView.ViewModel(id: UUID().uuidString, icon: .ic24Plus, title: "Пополнить", action: {})
    
    static let sampleDisabled = ButtonIconTextRectView.ViewModel(id: UUID().uuidString, icon: .ic24FileText, title: "Реквизиты и выписка", isEnabled: false, action: {})
}
