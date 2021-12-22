//
//  AntifraudView.swift
//  ForaBank
//
//  Created by Дмитрий on 08.12.2021.
//

import SwiftUI
import UIKit

class ContentViewDelegate: ObservableObject {
    @Published var back: String?
}

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct AntifraudView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var timeRemaining = 02*60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()


    
    let data: AntifraudViewModel

    @ObservedObject var delegate: ContentViewDelegate
    var present: (()->Void)?


    var body: some View {
        
//        let action: () -> Void = { DismissAction }
        
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
            Text(data.name)
                .font(.system(size: 16))
            Text(data.phoneNumber)
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            Text(data.amount)
                .font(.system(size: 24))
                .bold()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            Text("\(timeString(time: timeRemaining))")
                .foregroundColor(.red)
                    .onReceive(timer){ _ in
                        if self.timeRemaining > 0 {
                            self.timeRemaining -= 1
                        }else{
                            self.timer.upstream.connect().cancel()  
                            presentationMode.wrappedValue.dismiss()
                            let dic = ["Timer": true]
                            NotificationCenter.default.post(name: NSNotification.Name("dismissSwiftUI"), object: nil, userInfo: dic)

                        }
                    }
            HStack{
                Button("Отменить") {
                    presentationMode.wrappedValue.dismiss()
                    NotificationCenter.default.post(name: NSNotification.Name("dismissSwiftUI"), object: nil, userInfo: nil)
                    print("Отменить")
                    

                }
                .buttonStyle(StyledButton())

                Button("Продолжить") {
                    presentationMode.wrappedValue.dismiss()
                    print("Продолжить")
                }
                .buttonStyle(StyledButton())
            }
            .padding()
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        
    }
    
    func timeString(time: Int) -> String {
//        let hours   = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
}

struct StyledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(.black)
            .padding()
            .frame(width: 160, height: 40, alignment: .center)
            .background(Color(hex: "F2F4F5"))
            .cornerRadius(8)
    }
}

struct AntifraudView_Previews: PreviewProvider {
    static var previews: some View {
        AntifraudView(data: AntifraudViewModel(model: CreateSFPTransferDecodableModel(statusCode: nil, errorMessage: nil, data: nil), phoneNumber: "+7 (925) 279-86-13"), delegate: ContentViewDelegate())
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
