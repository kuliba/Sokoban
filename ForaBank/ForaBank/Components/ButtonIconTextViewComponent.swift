//
//  ButtonIconTextView.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import SwiftUI

//MARK: - ViewModel

extension ButtonIconTextView {

    class ViewModel: ObservableObject, Identifiable, Hashable  {
        
        let icon: Image
        let title: String
        let orientationState: OrientationState
        let backgroundState: BackgroundState
        var id = UUID()
        let action: () -> Void
        
        enum OrientationState {
            
            case vertical
            case horizontal
        }
        
        enum BackgroundState {
            
            case circle
            case square
        }

        internal init(icon: Image, title: String, orientationState: OrientationState, backgroundState: BackgroundState, id: UUID = UUID(), action: @escaping () -> Void) {
            self.icon = icon
            self.title = title
            self.orientationState = orientationState
            self.backgroundState = backgroundState
            self.id = id
            self.action = action
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
        }
        
        static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
            
            lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct ButtonIconTextView: View {
    
    var viewModel: ViewModel
    
    var body: some View {

        Button {
            viewModel.action()
        } label: {
            
            VStack {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 28)
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 56, height: 56)

                    viewModel.icon
                        .foregroundColor(.black)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                }

                Text(verbatim: viewModel.title)
                    .font(.textBodySR12160())
                    .frame(width: 80, height: 32, alignment: .top)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

//MARK: - Preview

struct FastOperationButtonView_Previews: PreviewProvider {
    
    static var previews: some View {

        Group {
            ButtonIconTextView(viewModel: .telephoneTranslation)
            ButtonIconTextView(viewModel: .qrPayment)
            ButtonIconTextView(viewModel: .templates)
        }
    }
}

//MARK: - Preview Content

extension ButtonIconTextView.ViewModel {

    static let telephoneTranslation =  ButtonIconTextView.ViewModel.init(icon: .ic24Smartphone,
                                                                         title: "Перевод по телефону",
                                                                         orientationState: .vertical,
                                                                         backgroundState: .circle,
                                                                         action: {})
    
    static let qrPayment = ButtonIconTextView.ViewModel.init(icon: .ic24BarcodeScanner2,
                                                             title: "Оплата\nпо QR",
                                                             orientationState: .vertical,
                                                             backgroundState: .circle,
                                                             action: {})
    
    static let templates = ButtonIconTextView.ViewModel.init(icon: .ic24Star,
                                                             title: "Шаблоны",
                                                             orientationState: .vertical,
                                                             backgroundState: .circle,
                                                             action: {})
}
