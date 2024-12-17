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

        let trackSize: CGSize = .init(width: 51, height: 31)
        let thumbSize: CGSize = .init(width: 21, height: 21)
        let thumbOffset: CGFloat = 11

        init(isOn: Binding<Bool>) {
            _isOn = isOn
        }
    }
}

//MARK: - View

struct DepositToggleViewComponent: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        ZStack {

            Capsule()
                .stroke(viewModel.isOn ? Color.mainColorsWhite : Color.mainColorsGray, lineWidth: 1)
                .frame(width: viewModel.trackSize.width, height: viewModel.trackSize.height)

            Circle()
                .foregroundColor(viewModel.isOn ? Color.mainColorsWhite : Color.mainColorsGray)
                .frame(width: viewModel.thumbSize.width, height: viewModel.thumbSize.height)
                .offset(x:viewModel.isOn ? viewModel.thumbOffset : -viewModel.thumbOffset)
                .animation(.spring())

        }.onTapGesture {
            viewModel.isOn.toggle()
        }
    }
}

struct DepositToggleView: View {

    var body: some View {

        ZStack {

            DepositToggleViewComponent(viewModel: .init(isOn: .constant(true)))
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
