//
//  UnderConstructionView.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 28.04.2022.
//

import SwiftUI

struct UnderConstructionView: View {
    @ObservedObject
    var viewModel: UnderConstructionViewModel
    
    var body: some View {
        VStack(spacing: 80) {
            UnderConstructionTextBlockView(viewModel: viewModel)
            UnderConstructionButtonBlockView(viewModel: viewModel.buttonBlock)
        }
    }
}

//MARK: - TextBlock

struct UnderConstructionTextBlockView: View {
    let viewModel: UnderConstructionViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            viewModel.icon
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
            VStack(spacing: 12) {
                Text(viewModel.title)
                    .font(.textH3SB18240())
                Text(viewModel.subTitle)
                    .font(.textBodyMR14200())
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
    }
}

//MARK: - ButtonBlock

struct UnderConstructionButtonBlockView: View {
    @ObservedObject
    var viewModel: UnderConstructionViewModel.ButtonBlockViewModel
    
    var body: some View {
        
        VStack(spacing: 16) {
            ForEach(viewModel.buttons, id: \.self) { rowButtons in
                HStack(spacing: 16) {
                    ForEach(rowButtons) { button in
                        ButtonView(viewModel: viewModel, buttonVM: button)
                    }
                }
            }
        }
        .padding(20)
    }
}

//MARK: - OneButton

struct ButtonView: View {
    @ObservedObject
    var viewModel: UnderConstructionViewModel.ButtonBlockViewModel
    var buttonVM: UnderConstructionViewModel.ButtonBlockViewModel.ButtonViewModel
    
    private var isMailButton: Bool {
        if case .email( _) = buttonVM {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        Button {
            if isMailButton {
                guard SendMailView.isCanSendMail else { return }
                viewModel.isShowSendMail = true
            } else {
                guard let url = URL(string: buttonVM.appearance.url) else { return }
                UIApplication.shared.open(url)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                VStack {
                    buttonVM.appearance.icon
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.mainColorsBlack)
                        .padding(.top, 15)
                    Spacer()
                    Text(buttonVM.appearance.title)
                        .font(.textBodySM12160())
                        .foregroundColor(.mainColorsBlack)
                        .padding(.bottom, 10)
                }
            }
            .frame(height: 76)
            .if(isMailButton) { view in
                view.sheet(isPresented: $viewModel.isShowSendMail) {
                    SendMailView(mailAddress: buttonVM.appearance.url)
                }
            }
        }
    }
}

//MARK: - Conditional View Modifier

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

//MARK: - Preview

struct UnderConstructionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnderConstructionView(viewModel: UnderConstructionViewModel())
        }
    }
}
