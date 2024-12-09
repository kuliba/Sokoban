//
//  ConfirmViewComponent.swift
//  Vortex
//
//  Created by Pavel Samsonov on 12.06.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ConfirmView {

    class ViewModel: ObservableObject {

        let action: PassthroughSubject<Action, Never> = .init()

        @Published var prepareData: OpenAccountPrepareViewModel
        @Published var confirmCode: String
        @Published var enterCode: String
        @Published var isResendCode: Bool

        private var bindings = Set<AnyCancellable>()

        let title = "Введите код из СМС"
        let icon = Image("Confirm Code")

        lazy var textFieldToolbar: TextFieldToolbarView.ViewModel = {

            let doneButtonAction: () -> Void = { [weak self] in
                self?.action.send(ConfirmViewModelAction.Button.Done())
            }

            let closeButtonAction: () -> Void = { [weak self] in
                self?.action.send(ConfirmViewModelAction.Button.Close())
            }

            let equalityOTPLength = confirmCode.count == prepareData.otpLength

            return .init(
                text: confirmCode,
                doneButton: .init(isEnabled: equalityOTPLength, action: doneButtonAction),
                closeButton: .init(isEnabled: true, action: closeButtonAction))
        }()

        lazy var resendButton: ViewModel.ResendButtonViewModel = {
            .init { [weak self] in

                self?.isResendCode = false
                self?.action.send(ConfirmViewModelAction.Button.ResendCode())
            }
        }()

        var timerViewModel: TimerView.ViewModel?

        var color: Color {

            if enterCode.isEmpty {
                return .mainColorsRed
            }

            return .mainColorsGray
        }

        init(prepareData: OpenAccountPrepareViewModel, confirmCode: String) {

            self.prepareData = prepareData
            self.confirmCode = confirmCode

            enterCode = ""
            isResendCode = false

            bind()
        }

        private func bind() {

            $confirmCode
                .combineLatest($prepareData)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in

                    let confirmCode = data.0
                    let prepareData = data.1

                    textFieldToolbar.doneButton.isEnabled = confirmCode.count == prepareData.otpLength
                    
                    isResendCode = false
                    
                    if confirmCode.isEmpty == false {
                        timerViewModel = nil
                    }
                    
                }.store(in: &bindings)
            
            $isResendCode
                .combineLatest($prepareData)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let isResendCode = data.0
                    let prepareData = data.1
                    
                    guard confirmCode.isEmpty == true, isResendCode == false, prepareData.otpResendTime > 0 else {
                        return
                    }
                    
                    if textFieldToolbar.text.isEmpty == false {
                        textFieldToolbar.text = ""
                    }
                    
                    timerViewModel = makeTimer(delay: TimeInterval(prepareData.otpResendTime))
                    
                }.store(in: &bindings)

            textFieldToolbar.$text
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] text in

                    let equalityOTPLength = text.count == prepareData.otpLength
                    textFieldToolbar.doneButton.isEnabled = equalityOTPLength

                    enterCode = text

                }.store(in: &bindings)
        }

        private func makeTimer(delay: TimeInterval) -> TimerView.ViewModel {

            .init(delay: delay) { [weak self] in
                self?.isResendCode = true
            }
        }
    }
}

extension ConfirmView.ViewModel {

    // MARK: - Resend

    struct ResendButtonViewModel {

        let title: String
        let action: () -> Void

        init(title: String = "Отправить повторно", action: @escaping () -> Void) {

            self.title = title
            self.action = action
        }
    }
}

// MARK: - View

struct ConfirmView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        HStack(spacing: 20) {

            viewModel.icon
                .renderingMode(.original)
                .resizable()
                .frame(width: 22, height: 22)
                .padding(.top)

            VStack(alignment: .leading, spacing: 4) {

                HStack {

                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(viewModel.color)

                    Spacer()

                    if viewModel.confirmCode.isEmpty == true {

                        if viewModel.isResendCode == false {

                            if let timer = viewModel.timerViewModel {
                                TimerView(viewModel: timer)
                            }

                        } else {

                            ResendButton(viewModel: viewModel.resendButton)
                        }
                    } else {
                        
                        if viewModel.isResendCode == true {
                            
                            ResendButton(viewModel: viewModel.resendButton)
                        }
                    }
                    
                }.frame(height: 12)

                TextFieldToolbarView(viewModel: viewModel.textFieldToolbar)
                    .frame(height: 40)
            }
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .padding(.top, 68)
            ).foregroundColor(.mainColorsBlack)
        }
    }
}

extension ConfirmView {

    // MARK: - Resend

    struct ResendButton: View {

        let viewModel: ViewModel.ResendButtonViewModel

        var body: some View {

            Button(action: viewModel.action) {

                ZStack {

                    Color
                        .mainColorsGrayLightest
                        .cornerRadius(12)
                        .frame(width: 140, height: 24)

                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsBlack)
                }
            }
        }
    }
}

enum ConfirmViewModelAction {

    enum Button {

        struct Done: Action {}
        struct Close: Action {}
        struct ResendCode: Action {}
    }
}

// MARK: - Previews

struct ConfirmViewComponent_Previews: PreviewProvider {
    static var previews: some View {

        ConfirmView(viewModel: .init(prepareData: .init(), confirmCode: "567834"))
            .previewLayout(.sizeThatFits)
            .padding([.leading, .trailing, .bottom])
    }
}
