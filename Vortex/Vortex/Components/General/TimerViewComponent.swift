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

        let style: Style
        let onComplete: () -> Void

        private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        private var bindings = Set<AnyCancellable>()
        
        init(value: String, style: Style, delay: TimeInterval, onComplete: @escaping () -> Void) {
            
            self.value = value
            self.style = style
            self.delay = delay
            self.onComplete = onComplete
        }

        convenience init(style: Style = .general, delay: TimeInterval, onComplete: @escaping () -> Void) {

            self.init(
                value: "",
                style: style,
                delay: delay,
                onComplete: onComplete
            )
            
            value = delayFormat()
            bind()
        }
        
        enum Style {
            
            case general
            case order
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
        
        switch viewModel.style {
        case .general:
            
            HStack {
                
                Spacer()
                    .fixedSize()
                
                Text(viewModel.value)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsRed)
                
                Spacer()
            }
            .frame(width: 56)
            .offset(x: 16)
            
        case .order:
            
            Text(viewModel.value)
                .font(.textBodyMR14180())
                .foregroundColor(.mainColorsRed)
                .animation(nil, value: viewModel.value)
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
