//
//  TimerViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.06.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension TimerView {

    class ViewModel: ObservableObject {

        @Published var value: String

        var delay: TimeInterval
        let onComplete: () -> Void

        private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        private var bindings = Set<AnyCancellable>()

        init(value: String = "", delay: TimeInterval, onComplete: @escaping () -> Void) {

            self.value = value
            self.delay = delay
            self.onComplete = onComplete

            self.value = delayFormat()

            bind()
        }

        func bind() {

            timer
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in

                    delay -= 1

                    if delay <= 0 {

                        onComplete()
                        stopTimer()
                    }

                    value = delayFormat()

                }.store(in: &bindings)
        }


        func stopTimer() {

            timer.upstream.connect().cancel()
        }

        private func delayFormat() -> String {

            let time = DateComponentsFormatter.formatTime.string(from: delay)

            guard let time = time else {
                return "00:00"
            }

            return time
        }
    }
}

// MARK: - View

struct TimerView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        Text(viewModel.value)
            .font(.textBodySR12160())
            .foregroundColor(.mainColorsRed)
            .onDisappear {
                viewModel.stopTimer()
            }
    }
}

//MARK: - Preview Content

struct TimerViewPreview: View {

    @State var delay: TimeInterval = 60

    var body: some View {
        TimerView(viewModel: .init(delay: delay, onComplete: {}))
    }
}

// MARK: - Previews

struct TimerViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        TimerViewPreview()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
