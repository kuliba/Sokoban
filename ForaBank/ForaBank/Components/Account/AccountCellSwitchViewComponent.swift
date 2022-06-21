//
//  AccountCellSwitchViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 25.04.2022.
//

import SwiftUI

//MARK: - ViewModel

extension AccountCellSwitchView {
    
    class ViewModel: AccountCellDefaultViewModel, ObservableObject {
        
        var type: Kind
        
        @Published var isActive = true
        
        enum Kind {
            
            case faceId
            case notification
            
            var title: String {
                switch self {
                case .faceId:
                    return "Вход по Face ID"
                    
                case .notification:
                    return "Push-уведомления"
                
                }
            }
            
            var icon: Image {
                switch self {
                case .faceId:
                    return .ic24FaceId
                    
                case .notification:
                    return .ic24Bell
                
                }
            }
        }
        
        internal init(content: String, type: Kind, icon: Image, title: String? = nil) {
            self.type = type
            super.init(id: UUID(), icon: icon, content: content, title: title)
        }
        
        internal init(type: Kind, isActive: Bool) {
            self.type = type
            super.init(id: UUID(), icon: type.icon, content: type.title, title: nil)
            self.isActive = isActive
        }
    }
}

//MARK: - View

struct AccountCellSwitchView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.mainColorsGrayLightest)
                    .frame(width: 40, height: 40)
                
                viewModel.icon
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
                
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                if let placeholder = viewModel.title {
                    
                    Text(verbatim: placeholder)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                }
                
                Text(verbatim: viewModel.content)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                
            }
            
            Spacer()
            
            Toggle("", isOn: $viewModel.isActive)
                .frame(width: 50)
                .padding(.trailing, 6)
            
        }
        .frame(height: 56, alignment: .leading)
    }
}

//MARK: - Preview

struct AccountCellSwitchView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            AccountCellSwitchView(viewModel: .appleId)
                .previewLayout(.fixed(width: 375, height: 80))
            AccountCellSwitchView(viewModel: .push)
                .previewLayout(.fixed(width: 375, height: 80))
        }
    }
}

//MARK: - Preview Content

extension AccountCellSwitchView.ViewModel {
    
    static let appleId = AccountCellSwitchView.ViewModel
        .init(type: .faceId, isActive: true)
    
    static let push = AccountCellSwitchView.ViewModel
        .init(type: .notification, isActive: false)
    
}

