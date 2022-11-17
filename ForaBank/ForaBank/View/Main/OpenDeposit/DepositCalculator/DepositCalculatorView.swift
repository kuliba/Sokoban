//
//  DepositCalculatorView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 02.05.2022.
//

import SwiftUI

struct DepositCalculatorView: View {

    let viewModel: DepositCalculatorViewModel

    var body: some View {

        ZStack {

            VStack(alignment: .leading) {

                DepositTitleView(viewModel: viewModel)

                if let capitalization = viewModel.capitalization {
                    DepositCapitalizationView(viewModel: capitalization)
                }

                DepositCalculateAmountView(viewModel: viewModel.calculateAmount)
                DepositTotalAmountView(viewModel: viewModel.totalAmount)
            }
            .background(Color.mainColorsBlack)
            .cornerRadius(12)
        }
    }
}

// MARK: - Content

extension DepositCalculatorView {

    struct DepositTitleView: View {

        let viewModel: DepositCalculatorViewModel

        var body: some View {

            Text(viewModel.title)
                .font(.textH2SB20282())
                .foregroundColor(.mainColorsWhite)
                .padding(20)
        }
    }

    struct DepositContainerBottomSheetView<Content: View>: View {

        @Binding var isOpen: Bool

        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

        let maxHeight: CGFloat
        let minHeight: CGFloat
        let content: Content

        @GestureState private var translation: CGFloat = 0

        private var offset: CGFloat {
            isOpen ? 0 : maxHeight + minHeight
        }

        private var indicator: some View {

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.mainColorsGrayMedium)
                .opacity(0.7)
                .frame( width: 48, height: 4)
                .onTapGesture {
                    isOpen.toggle()
                }
        }

        init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {

            self.minHeight = maxHeight * 0.3
            self.maxHeight = maxHeight
            self.content = content()
            self._isOpen = isOpen
        }

        var body: some View {

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    indicator.padding()
                    content
                }
                .background(Color.mainColorsWhite)
                .cornerRadius(12)
                .frame(height: geometry.size.height, alignment: .bottom)
                .offset(y: max(offset + translation, 0))
                .animation(.spring())
                .shadow(color: .mainColorsGrayMedium, radius: 2, x: 0, y: 2)
                .gesture(
                    DragGesture().updating($translation) { value, state, _ in

                        state = value.translation.height

                    }.onEnded { value in

                        let snapDistance = self.maxHeight * 0.25

                        guard abs(value.translation.height) > snapDistance else {
                            return
                        }

                    action: do { self.isOpen.toggle() }
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - Preview

struct DepositCalculatorView_Previews: PreviewProvider {
    static var previews: some View {

        Group {

            DepositCalculatorView(viewModel: .sample1)
                .previewLayout(.sizeThatFits)
                .padding()

            DepositCalculatorView(viewModel: .sample2)
                .previewLayout(.sizeThatFits)
                .padding()

        }.background(Color.mainColorsGray)
    }
}
