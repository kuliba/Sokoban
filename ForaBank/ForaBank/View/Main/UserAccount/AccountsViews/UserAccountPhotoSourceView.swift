//
//  UserAccountPhotoSourceView.swift
//  ForaBank
//
//  Created by Mikhail on 28.06.2022.
//

import SwiftUI

extension UserAccountPhotoSourceView {
    
    class ViewModel: ObservableObject {
        
        let items: [ButtonViewModel]
            
        internal init(items: [ButtonViewModel]) {
            
            self.items = items
        }
        
        struct ButtonViewModel: Identifiable {
            
            let id = UUID()
            let icon: Image
            let content: String
            
            let action: () -> Void
            
            internal init(icon: Image, content: String, action: @escaping () -> Void) {
                
                self.icon = icon
                self.content = content
                self.action = action
            }
        }
    }
}

struct UserAccountPhotoSourceView: View {
    
    @ObservedObject var viewModel: UserAccountPhotoSourceView.ViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            ForEach(viewModel.items) { item in
                
                Button {
                    
                    item.action()
                    
                } label: {
                    
                    HStack(spacing: 20) {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.bGIconGrayLightest)
                                .frame(width: 40, height: 40)
                            
                            item.icon
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.iconBlack)
                        }
                        
                        Text(verbatim: item.content)
                            .font(.textH4M16240())
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

struct UserAccountCameraSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountPhotoSourceView(viewModel: .init(items: [
            .init(icon: .ic24Camera, content: "Сделать фото", action: { }),
            .init(icon: .ic24Image, content: "Выбрать из галереи", action: { })
        ]))
    }
}
