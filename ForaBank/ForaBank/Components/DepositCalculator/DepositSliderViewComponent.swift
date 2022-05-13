//
//  DepositSliderViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 02.05.2022.
//

import SwiftUI

//MARK: - ViewModel

extension DepositSliderViewComponent {

    class ViewModel: ObservableObject {

        @Binding var value: Double
        let bounds: ClosedRange<Double>

        init(value: Binding<Double>, bounds: ClosedRange<Double>) {

            _value = value
            self.bounds = bounds
        }
    }
}

//MARK: - View

struct DepositSliderViewComponent: View {

    @ObservedObject var viewModel: ViewModel

    @State private var offset: Double
    @State private var lastOffset: Double
    @State private var trackSize: CGSize

    private let thumbSize: CGSize
    private let step: Double

    init(viewModel: ViewModel,
         offset: Double = 0,
         lastOffset: Double = 0,
         trackSize: CGSize = .zero,
         thumbSize: CGSize = .init(width: 20, height: 20),
         step: Double = 1000) {

        self.viewModel = viewModel
        self.offset = offset
        self.lastOffset = lastOffset
        self.trackSize = trackSize
        self.thumbSize = thumbSize
        self.step = step
    }

    var body: some View {

        ZStack(alignment: .leading) {

            makeTrack()
            makeFill()
            makePoints()
            makeThumb()
        }
    }
}

extension DepositSliderViewComponent {

    private var points: [Double] {

        if viewModel.bounds.upperBound == Points.loanFiveMillion {
            return [viewModel.bounds.lowerBound, Points.minValue, Points.maxValue]
        }

        return [viewModel.bounds.lowerBound]
    }

    private var stickingRange: ClosedRange<Double> {
        viewModel.value - Points.offsetToStick...viewModel.value + Points.offsetToStick
    }

    private var thumbOffset: Double {

        if viewModel.value >= 0 {

            DispatchQueue.main.async {
                withAnimation {
                    offset = offset(viewModel.value)
                }
            }
        }

        return offset
    }

    enum Points {

        static let minValue: Double = 1500000
        static let maxValue: Double = 3000000

        static let offsetToStick: Double = 200000
        static let loanFiveMillion: Double = 5000000
    }
}

extension DepositSliderViewComponent {

    private func percentage(_ value: Double) -> Double {
        1 - (viewModel.bounds.upperBound - value) / (viewModel.bounds.upperBound - viewModel.bounds.lowerBound)
    }

    private func offset(_ value: Double = 0) -> Double {
        (trackSize.width - thumbSize.width) * percentage(value)
    }

    private func offset(_ value: Double, index: Int) -> Double {

        if index == 0 {
            return offset()
        }

        return offset(value) + thumbSize.width / 3
    }
}

extension DepositSliderViewComponent {

    private func makeTrack() -> some View {

        Capsule()
            .foregroundColor(.mainColorsBlackMedium)
            .frame(height: 2)
            .modifier(DepositSliderViewModifier())
            .onPreferenceChange(DepositSliderPreferenceKey.self) { value in

                guard trackSize == .zero else {
                    return
                }

                trackSize = value
                offset = offset(viewModel.value)
                lastOffset = offset
            }
    }

    private func makeFill() -> some View {

        Capsule()
            .foregroundColor(.mainColorsRed)
            .frame(width: thumbOffset, height: trackSize.height)
    }

    private func makeThumb() -> some View {

        Circle()
            .foregroundColor(.mainColorsBlack)
            .overlay(
                RoundedRectangle(cornerRadius: trackSize.width)
                    .stroke(Color.mainColorsRed, lineWidth: 2)
            )
            .frame(width: thumbSize.width, height: thumbSize.height)
            .offset(x: thumbOffset)
            .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in

                onChanged(value.translation.width)

            }.onEnded { _ in

                stickToPoint()
            })
    }

    private func makePoints() -> some View {

        return ForEach(0...points.count - 1, id:\.self) { index in

            let point = points[index]
            let color: Color = viewModel.value >= point ? .mainColorsRed : .mainColorsBlackMedium

            color
                .cornerRadius(3)
                .frame(width: 6, height: 6)
                .offset(x: offset(point, index: index))
                .onTapGesture {

                    withAnimation {
                        viewModel.value = point
                        offset = offset(viewModel.value)
                    }
                }
        }
    }

    private func onChanged(_ width: Double) {

        if abs(width) < 0.1 {
            lastOffset = offset
        }

        let availableWidth = trackSize.width - thumbSize.width
        offset = max(0, min(lastOffset + width, availableWidth))
        let newValue = (viewModel.bounds.upperBound - viewModel.bounds.lowerBound) * Double(offset / availableWidth) + viewModel.bounds.lowerBound
        let steppedValue = (round(newValue / step) * step)
        viewModel.value = min(viewModel.bounds.upperBound, max(viewModel.bounds.lowerBound, steppedValue))
    }

    private func stickToPoint() {

        let stickingPoint = points.first { value in

            guard value > Points.offsetToStick else {
                return false
            }

            return stickingRange ~= value
        }

        guard let value = stickingPoint else {
            return
        }

        withAnimation {

            viewModel.value = value
            offset = offset(value)
        }
    }
}

struct DepositSliderPreferenceKey: PreferenceKey {

    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct DepositSliderViewModifier: ViewModifier {

    func body(content: Content) -> some View {

        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: DepositSliderPreferenceKey.self, value: proxy.size)
            }
        )
    }
}

struct DepositSliderView: View {

    @State private var value: Double = 1000000

    var body: some View {

        VStack {

            Text("\(Int(value))")
                .foregroundColor(.mainColorsWhite)

            DepositSliderViewComponent(
                viewModel: .init(
                    value: $value,
                    bounds: 10000...5000000)
            ).padding([.leading, .trailing])
        }
        .frame(height: 84)
        .background(Color.mainColorsBlack)
    }
}

struct DepositSliderViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        DepositSliderView()
            .previewLayout(.sizeThatFits)
    }
}
