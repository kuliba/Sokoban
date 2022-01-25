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


    let viewModel: AntifraudViewModel
    
    @ObservedObject var delegate: ContentViewDelegate
    
    var present: (()->Void)?


    var body: some View {
        
        VStack {
            Image("antifraud")
                .frame(width: 64, height: 64, alignment: .center)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            Text("Подозрительные действия")
                .bold()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                .font(.system(size: 16))
            VStack {
                Text("Есть подозрения в попытке совершения\n мошеннических операций")
                    .padding(EdgeInsets(top: 0, leading: 40, bottom: 15, trailing: 40))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(viewModel.name)
                .font(.system(size: 16))
            Text(viewModel.phoneNumber)
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            Text(viewModel.amount)
                .font(.system(size: 24))
                .bold()
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            Text("\(timeString(time: timeRemaining))")
                .foregroundColor(.red)
                    .onReceive(timer){ _ in
                        if self.timeRemaining > 0 {
                            self.timeRemaining -= 1
                        }else{
                            self.timer.upstream.connect().cancel()  
                            viewModel.timerAction()

                        }
                    }
            HStack{
                Button("Отменить") {
                    viewModel.cancelAction()
                }
                .buttonStyle(StyledButton())
                
                Button(action: {
                    viewModel.dismissAction()
                })  {
                         Text("Продолжить")
                     }
                .buttonStyle(StyledButton())

            }
            .padding()
        }
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        .transition(.scale)
        .edgesIgnoringSafeArea(.bottom)
        
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
        AntifraudView(viewModel: AntifraudViewModel(model: CreateSFPTransferDecodableModel(statusCode: nil, errorMessage: nil, data: nil), phoneNumber: "+7 (925) 279-86-13"), delegate: ContentViewDelegate())
    }
}
