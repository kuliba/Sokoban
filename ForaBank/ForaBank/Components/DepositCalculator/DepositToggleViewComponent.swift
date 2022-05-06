//
//  DepositToggleViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 02.05.2022.
//

import SwiftUI

//MARK: - ViewModel

extension DepositToggleViewComponent {

    class ViewModel: ObservableObject {

        @Binding var isOn: Bool

        init(isOn: Binding<Bool>) {
            _isOn = isOn
        }
    }
}

//MARK: - View

struct DepositToggleViewComponent: View {

    @Binding var isOn: Bool

    var body: some View {

        ZStack {

            Capsule()
                .stroke(isOn ? Color.mainColorsWhite : Color.mainColorsGray, lineWidth: 1)
                .frame(width: Const.trackSize.width, height: Const.trackSize.height)

            Circle()
                .foregroundColor(isOn ? Color.mainColorsWhite : Color.mainColorsGray)
                .frame(width: Const.thumbSize.width, height: Const.thumbSize.height)
                .offset(x:isOn ? Const.thumbOffset : -Const.thumbOffset)
                .animation(.spring())

        }.onTapGesture {
            isOn.toggle()
        }
    }
}

extension DepositToggleViewComponent {

    enum Const {

        static let trackSize: CGSize = .init(width: 51, height: 31)
        static let thumbSize: CGSize = .init(width: 21, height: 21)
        static let thumbOffset: CGFloat = 11
    }
}

struct DepositToggleView: View {

    var body: some View {

        ZStack {

            DepositToggleViewComponent(isOn: .constant(true))
        }
        .frame(width: 375, height: 64)
        .background(Color.mainColorsBlackMedium)
    }
}

struct DepositToggleViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        DepositToggleView()
            .previewLayout(.sizeThatFits)
    }
}
