//
//  AuthPermissionsView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2022.
//

import SwiftUI

struct AuthPermissionsView: View {
    
    @ObservedObject var viewModel: AuthPermissionsViewModel
    
    var body: some View {
        
        VStack{
            
            HeaderView(viewModel: viewModel.header)
            
            Spacer()
            
            ButtonsView(viewModel: viewModel.buttons)
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
    }
}


extension AuthPermissionsView {
    
    struct HeaderView: View {
        
        let viewModel: AuthPermissionsViewModel.HeaderViewModel
        
        var body: some View {
            
            VStack(spacing: 32) {
                
                ZStack(alignment: .center) {
                    Circle()
                        .fill(Color.bGIconGrayLightest)
                        .frame(width: 170, height: 170)
                    viewModel.icon
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                }
                
                Text(viewModel.title)
                    .font(.textH4R16240())
                    .foregroundColor(.textPlaceholder)
                    .padding([.leading,.trailing], 20)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        }
    }
    
    struct ButtonsView: View {
        
        let viewModel: [AuthPermissionsViewModel.ButtonViewModel]
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                ForEach(viewModel){ buttonViewModel in
                    
                    Button {
                        
                        buttonViewModel.action()
                    } label: {
                        
                        Text(buttonViewModel.title)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                    .background(buttonViewModel.style.background)
                    .font(.buttonLargeSB16180())
                    .foregroundColor(buttonViewModel.style.textColor)
                    .cornerRadius(8)
                    
                }
            }
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        }
    }
}

struct AuthPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        AuthPermissionsView(viewModel: AuthPermissionsViewModel(Model.emptyMock))
    }
}
