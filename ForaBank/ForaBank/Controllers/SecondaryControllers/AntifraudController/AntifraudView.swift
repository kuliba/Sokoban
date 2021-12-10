//
//  AntifraudView.swift
//  ForaBank
//
//  Created by Дмитрий on 08.12.2021.
//

import SwiftUI

struct AntifraudView: View {
    var body: some View {
        
        let title: String = "Do Something!"
        let action: () -> Void = { /* DO SOMETHING */ }
        
        VStack {
            Image("antifraud")
                .frame(width: 64, height: 64, alignment: .center)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            Text("Подозрительные действия")
                .bold()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                .font(.system(size: 16))
            Text("Есть подозрения в попытке совершения мошеннических операций")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .font(.system(size: 13))
            Text("Юрий Андреевич К.")
                .font(.system(size: 16))
            Text("+7 (903) 324-54-15")
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            Text("- 1 000,00 ₽")
                .font(.system(size: 24))
                .bold()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            HStack{
                Button("Отменить") {
                    print("Отменить")
                }
                .buttonStyle(StyledButton())
                Button("Продолжить") {
                    print("Продолжить")
                }
                .buttonStyle(StyledButton())
            }

        }
        
    }
}

struct StyledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(.black)
            .padding()
            .background(Color(UIColor.init(hex: "F2F4F5") ?? .clear))
            .cornerRadius(8)
    }
}

struct AntifraudView_Previews: PreviewProvider {
    static var previews: some View {
        AntifraudView()
    }
}
