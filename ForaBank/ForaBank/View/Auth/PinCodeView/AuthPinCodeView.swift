//
//  PinCodeView.swift
//  ForaBank
//
//  Created by Дмитрий on 11.02.2022.
//

import SwiftUI

struct AuthPinCodeView: View {
    
    @ObservedObject var viewModel: AuthPinCodeViewModel
    
    var body: some View {
        
        VStack() {
            
            PinCodeView(viewModel: viewModel.pinCode)
            
            KeyPad(string: $string, viewModel: viewModel.numpad)
            
            Spacer()
            
            ButtonsView(viewModel: viewModel.bottomButton)
        }
        .padding([.top], 80)
    }
    
    @State private var string = "0"

}


extension AuthPinCodeView{
    
    struct KeyPad: View {
        
        @Binding var string: String
        
        var viewModel: [[AuthPinCodeViewModel.ButtonViewModel?]]

        var body: some View {
            VStack(spacing: 24){
                
//                ForEach(viewModel){ button in
//                   HStack {
////                     TextField("PlaceHolder", text: "")
//                   }
//                }
//                    ForEach(i) { buttons in
//                            buttons.title
//                    }
//                if let viewModel = viewModel[0]{
//
//                    
//                }

                KeyPadRow(keys: ["1", "2", "3"])
                KeyPadRow(keys: ["4", "5", "6"])
                KeyPadRow(keys: ["7", "8", "9"])
                KeyPadRow(keys: ["Выход", "0", "⌫"])
            }
        }
    }
    
    struct ButtonsView: View {
        
        @State var viewModel: AuthPinCodeViewModel.FooterViewModel

        var body: some View {
            
            HStack {
                
                if let cancelButton =  viewModel.cancelButton {
                    
                    Button {
                        
                        cancelButton.action()
                    } label: {
                        
                        Text(cancelButton.title)
                    }
                    .foregroundColor(.textSecondary)
                    .font(.textH4SB16240())
                }
                
                Spacer()
                
                if let continueButton =  viewModel.continueButton{
                    
                    Button {
                        
                        continueButton.action()
                    } label: {
                        
                        Text(continueButton.title)
                    }
                    .foregroundColor(.textSecondary)
                    .font(.textH4SB16240())
                }
            }
            .padding([.leading,.trailing, .bottom], 20)
        }
    }
    
    struct PinCodeView: View {
        
        @State var viewModel: AuthPinCodeViewModel.PinCodeViewModel
        
        var body: some View {
       
            Text(viewModel.title)
                    .font(.textH4M16240())
                    .padding([.bottom], 40)
            
            HStack(alignment: .center, spacing: 16){
                
                ForEach(viewModel.code, id: \.self) { pin in
                    
                    switch viewModel.state{
                        
                    case .editing:
                        
                        Circle()
                                .frame(width: 12, height: 12, alignment: .center)
                                .foregroundColor(.mainColorsGrayMedium)
                    case .incorrect:
                        
                        Circle()
                                .frame(width: 12, height: 12, alignment: .center)
                                .foregroundColor(.systemColorError)
                    case .correct:
                        
                        Circle()
                                .frame(width: 12, height: 12, alignment: .center)
                                .foregroundColor(.systemColorActive)
                    }
                    
                }
            }
            .padding([.bottom], 52)
        }
    }
}

struct KeyPadRow: View {
    
    var keys: [String]

    var body: some View {
        HStack(spacing: 20) {
            ForEach(keys, id: \.self) { key in
                    KeyPadButton(key: key)
            }
        }
    }
}

struct KeyPadButton: View {
    
    var key: String

    var body: some View {
        
        HStack{
            if key == "⌫"{
                
                Button(action: { print("") }) {
                    Image.ic40Delete
                        .renderingMode(.original)
                }

                .frame(width: 80, height: 80, alignment: .center)
            } else if key == "Выход" {
                
  
                Button(action: { print("") }) {
                    
                    Color.mainColorsGrayLightest
                        .overlay(
                            Text(key)
                                .font(.textBodyMSB14200())
                        )
                        .foregroundColor(Color.textSecondary)
                }
                .cornerRadius(50)
                .frame(width: 80, height: 80, alignment: .center)
            } else {

                Button(action: { print("") }) {
                    Color.mainColorsGrayLightest
                        .overlay(
                            Text(key)
                                .font(.textH1R24322())
                        )
                        .foregroundColor(Color.textSecondary)
                }
                .cornerRadius(50)
                .frame(width: 80, height: 80, alignment: .center)
            }
        }
    }
}

struct PinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        AuthPinCodeView(viewModel: AuthPinCodeViewModel())
    }
}
