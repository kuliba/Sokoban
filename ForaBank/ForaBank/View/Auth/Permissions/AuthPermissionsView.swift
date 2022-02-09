//
//  AuthPermissionsView.swift
//  ForaBank
//
//  Created by Дмитрий on 09.02.2022.
//

import SwiftUI

struct AuthPermissionsView: View {

    var viewModel: AuthPermissionsViewModel
    
    var body: some View {
        VStack{
            
            HeaderView(viewModel: viewModel.header)
            Spacer()
            ButtonsView(viewModel: viewModel.buttons)
        }
        .padding(EdgeInsets(top: 24, leading: 20, bottom: 20, trailing: 20))
    }
}


extension AuthPermissionsView {
    
    struct HeaderView: View {
        
        @State var viewModel: AuthPermissionsViewModel.HeaderViewModel
        
        var body: some View {

            VStack(spacing: 24) {
                ZStack(alignment: .center) {
                    Circle()
                        .fill(.gray)
                        .frame(width: 170, height: 170)
                    viewModel.icon
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                }
                
                Text(viewModel.title)
                    .foregroundColor(.textPlaceholder)
                    .padding([.leading,.trailing], 20)
                    .multilineTextAlignment(.center)
            }
            .padding(EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0))
        }
    }
    
    struct ButtonsView: View {
        
        @State var viewModel: [AuthPermissionsViewModel.ButtonViewModel]
        
        var body: some View {
            VStack(spacing: 8) {
                ForEach(0..<viewModel.count) { i in
                        Button {
                            
                            viewModel[i].action()
                        } label: {
                            
                            Text(verbatim: viewModel[i].title)
                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                        .background(Color.red)
                        .foregroundColor(.white)
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
