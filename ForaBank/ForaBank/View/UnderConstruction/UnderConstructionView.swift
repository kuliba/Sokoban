//
//  UnderConstructionView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 28.04.2022.
//

import SwiftUI

struct UnderConstructionView: View {
    var body: some View {
        VStack(spacing: 80) {
            UnderConstructionTextBlockView()
            UnderConstructionButtonBlockView()
        }
    }
}

//MARK: - TextBlock

struct UnderConstructionTextBlockView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image.ic48Tool
            VStack(spacing: 12) {
                Text("Раздел еще в разработке")
                    .font(.textH3SB18240())
                Text("Вы всегда можете обратиться в нашу службу поддержки с вопросами и предложениями")
                    .font(.textBodyMR14200())
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

//MARK: - ButtonBlock

struct UnderConstructionButtonBlockView: View {
    var body: some View {
        
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ForEach(0..<2) { _ in ButtonView() }
            }
            HStack(spacing: 16) {
                ForEach(0..<3) { _ in ButtonView() }
            }
        }
        .padding(20)
    }
}

struct ButtonView: View {
    var body: some View {
        Button {
            print("Tapped")
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                VStack {
                    Image.ic24Mail //Image.ic16PhoneOutgoing
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.mainColorsBlack)
                        .padding(.top, 15)
                    Spacer()
                    Text("Отправить e-mail")
                        .font(.textBodySM12160())
                        .foregroundColor(.mainColorsBlack)
                        .padding(.bottom, 10)
                }
            }
            .frame(height: 76)
        }
    }
}

//MARK: - Preview

struct UnderConstructionView_Previews: PreviewProvider {
    static var previews: some View {
        UnderConstructionView()
    }
}
