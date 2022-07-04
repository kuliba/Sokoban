//
//  InformerViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 30.06.2022.
//

import SwiftUI

extension InformerView {

    class ViewModel: ObservableObject {

        @Published var message: String
        @Published var isShow: Bool

        let icon: Image
        let color: Color

        init(message: String = "",
             isShow: Bool = false,
             icon: Image = .init("Check Info Enabled"),
             color: Color = .systemColorWarning) {

            self.message = message
            self.isShow = isShow
            self.icon = icon
            self.color = color
        }
    }
}

struct InformerView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        if viewModel.isShow {

            ZStack {

                HStack(spacing: 10) {

                    viewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text(viewModel.message)
                        .font(.textH4R16240())
                        .foregroundColor(.mainColorsWhite)
                }
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 12)

            }
            .background(viewModel.color)
            .cornerRadius(8)

        } else {

            Color.clear
        }
    }
}

struct InformerViewComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {

            InformerView(viewModel: .init(message: "USD счет открывается"))
            InformerView(viewModel: .init(message: "USD счет открыт"))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
