//
//  UserAccountView.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import Combine
import LandingUIComponent
import OTPInputComponent
import Presentation
import ManageSubscriptionsUI
import SearchBarComponent
import SwiftUI
import UserAccountNavigationComponent
import UIPrimitives

struct UserAccountView: View {
    
    @ObservedObject var viewModel: UserAccountViewModel
    
    var body: some View {
        
        ZStack {
            
            scrollView
            
            viewModel.route.spinner.map(SpinnerView.init(viewModel:))
        }
    }
    
    var scrollView: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 20) {
                
                avatarView
                
                ForEach(viewModel.sections, content: sectionView)
                
                exitButton
                deleteAccountButton
                appVersionFullView
            }
            .navigationDestination(
                item: .init(
                    get: { viewModel.route.link },
                    set: { if $0 == nil { viewModel.resetLink() }}
                ),
                content: destinationView(link:)
            )
        }
        .sheet(
            item: .init(
                get: { viewModel.route.sheet },
                set: { if $0 == nil { viewModel.resetSheet() }}
            ),
            content: sheetView
        )
        .bottomSheet(
            item: .init(
                get: { viewModel.route.bottomSheet },
                set: { if $0 == nil { viewModel.resetBottomSheet() }}
            ),
            content: bottomSheetView
        )
        .alert(
            item: .init(
                get: { viewModel.route.alert },
                set: { if $0 == nil { viewModel.resetAlert() }}
            ),
            content: { .init(with: $0, event: { viewModel.event(.alertButtonTapped($0)) }) }
        )
        .textfieldAlert(
            alert: .init(
                get: { viewModel.route.textFieldAlert },
                set: { if $0 == nil { viewModel.resetTextFieldAlert() }}
            )
        )
        .navigationBarTitle("", displayMode: .inline)
        .navigationBar(with: viewModel.navigationBar)
    }
    
    var avatarView: some View {
        
        ZStack {
            
            if let avatar = viewModel.avatar {
                
                if let avatarImage = avatar.image {
                    
                    avatarImage
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 96, height: 96)
                        .overlay(Circle()
                            .stroke(lineWidth: 0)
                        )
                    
                } else {
                    
                    //Avatar Placeholder
                    Circle()
                        .foregroundColor(.mainColorsGrayLightest)
                        .frame(width: 96, height: 96)
                    
                    Image.ic24User
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.iconGray)
                }
                
                Button(action: avatar.action) {
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(.iconBlack)
                            .frame(width: 32, height: 32)
                        
                        Image.ic16Edit2
                            .foregroundColor(.iconWhite)
                    }
                }
                .offset(x: 32, y: -32)
            }
        }
    }
    
    @ViewBuilder
    private func sectionView(
        section: UserAccountViewModel.AccountSectionViewModel
    ) -> some View {
        
        switch section {
            
        case let sectionViewModel as UserAccountContactsView.ViewModel:
            UserAccountContactsView(viewModel: sectionViewModel)
            
        case let sectionViewModel as UserAccountPaymentsView.ViewModel:
            UserAccountPaymentsView(viewModel: sectionViewModel)
            
        case let sectionViewModel as UserAccountSecurityView.ViewModel:
            UserAccountSecurityView(viewModel: sectionViewModel)
            
        case let sectionViewModel as UserAccountDocumentsView.ViewModel:
            UserAccountDocumentsView(viewModel: sectionViewModel)
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var exitButton: some View {
        
        viewModel.exitButton.map {
            
            AccountCellFullButtonView(viewModel: $0)
                .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var deleteAccountButton: some View {
        
        viewModel.deleteAccountButton.map {
            
            AccountCellFullButtonWithInfoView(viewModel: $0)
                .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var appVersionFullView: some View {
        
        viewModel.appVersionFull.map {
            
            Text($0)
                .foregroundColor(Color.textPlaceholder)
                .lineLimit(1)
                .font(.textH4R16240())
        }
    }
    
    @ViewBuilder
    private func destinationView(
        link: UserAccountRoute.Link
    ) -> some View {
        
        switch link {
            
        case let .userDocument(userDocumentViewModel):
            UserDocumentView(viewModel: userDocumentViewModel)
            
        case let .fastPaymentSettings(fastPaymentSettings):
            switch fastPaymentSettings {
            case let .legacy(meToMeSettingsViewModel):
                MeToMeSettingView(viewModel: meToMeSettingsViewModel)
                    .navigationBarBackButtonHidden(false)
                    .navigationBarTitle("", displayMode: .inline)
                
            case let .new(route):
                fpsWrapperView(route)
            }
            
        case let .deleteUserInfo(deleteInfoViewModel):
            DeleteAccountView(viewModel: deleteInfoViewModel)
                .navigationBarBackButtonHidden(true)
            
        case let .imagePicker(imagePicker):
            ImagePicker(viewModel: imagePicker)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(false)
                .navigationBarTitle("Выберите фото", displayMode: .inline)
            
        case let .managingSubscription(subscriptionViewModel):
            ManagingSubscriptionView(
                subscriptionViewModel: subscriptionViewModel,
                configurator: .init(
                    titleFont: .textBodyMR14180(),
                    titleColor: .textPlaceholder,
                    nameFont: .textH4M16240(),
                    nameColor: .mainColorsBlack,
                    descriptionFont: .textBodyMR14180()
                ),
                footerImage: Image.ic72Sbp,
                searchCancelAction: subscriptionViewModel.searchViewModel.dismissKeyboard
            )
            
        case let .successView(successViewModel):
            PaymentsSuccessView(viewModel: successViewModel)
        }
    }
    
    private func fpsWrapperView(
        _ route: UserAccountNavigation.State.FPSRoute
    ) -> some View {
        
        FastPaymentsSettingsWrapperView(
            viewModel: route.viewModel,
            config: .preview
        )
        .navigationBar(with: .fastPayments(
            action: viewModel.dismissDestination
        ))
        .alert(
            item: .init(
                get: { viewModel.route.fpsAlert },
                // set: { if $0 == nil { viewModel.event(.closeFPSAlert) }}
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: { viewModel.event(.init(event: $0)) }) }
        )
        .navigationDestination(
            item: .init(
                get: { viewModel.route.fpsDestination },
                set: { _ in }//{ if $0 == nil { viewModel.event(.dismissFPSDestination) }}
            ),
            content: fpsDestinationView
        )
    }
    
    @ViewBuilder
    private func fpsDestinationView(
        fpsDestination: UserAccountNavigation.State.FPSDestination
    ) -> some View {
        
        switch fpsDestination {
        case let .confirmSetBankDefault(timedOTPInputViewModel, _):
            OTPInputWrapperView(viewModel: timedOTPInputViewModel)
            
        case let .c2BSub(getC2BSubResponse, _):
            Text("TBD: \(String(describing: getC2BSubResponse))")
        }
    }
    
    @ViewBuilder
    private func sheetView(
        sheet: UserAccountRoute.Sheet
    ) -> some View {
        
        switch sheet.sheetType {
        case let .userDocument(userDocumentViewModel):
            UserDocumentView(viewModel: userDocumentViewModel)
        }
    }
    
    @ViewBuilder
    private func bottomSheetView(
        sheet: UserAccountRoute.BottomSheet
    ) -> some View {
        
        switch sheet.sheetType {
            
        case let .deleteInfo(model):
            UserAccountExitInfoView(viewModel: model)
            
        case let .inn(model):
            UserAccountDocumentInfoView(viewModel: model)
            
        case let .camera(model):
            UserAccountPhotoSourceView(viewModel: model)
            
        case let .avatarOptions(optionViewModel):
            OptionsButtonsViewComponent(viewModel: optionViewModel)
            
        case let .imageCapture(imageCapture):
            ImageCapture(viewModel: imageCapture)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(false)
            
        case let .sbpay(viewModel):
            SbpPayView(viewModel: viewModel)
        }
    }
}

private extension UserAccountEvent {
    
    init(event: UserAccountNavigation.Event) {
        
        switch event {
        case .closeAlert:
            self = .closeAlert
            
        case .closeFPSAlert:
            self = .closeFPSAlert
            
        case .dismissDestination:
            self = .dismissDestination
            
        case .dismissFPSDestination:
            self = .dismissFPSDestination
            
        case .dismissRoute:
            self = .dismissRoute
            
        case let .fps(fps):
            self = .fps(fps)
            
        case let .otp(otp):
            self = .otp(otp)
        }
    }
}

private extension UserAccountRoute {
    
    var fpsAlert: AlertModelOf<UserAccountNavigation.Event>? {
        
        fpsRoute?.alert
    }
    
    var fpsDestination: UserAccountNavigation.State.FPSDestination? {
        
        fpsRoute?.destination
    }
    
    private var fpsRoute: UserAccountNavigation.State.FPSRoute? {
        
        switch link {
        case let .fastPaymentSettings(.new(fpsRoute)):
            return fpsRoute
            
        default:
            return nil
        }
    }
}

private struct OTPInputWrapperView: View {
    
    @ObservedObject private var viewModel: TimedOTPInputViewModel
    
    init(viewModel: TimedOTPInputViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        switch viewModel.state {
        case .failure:
            EmptyView()
            
        case let .input(input):
            OTPInputView(
                state: input,
                phoneNumber: "TBD: hardcoded phone number",
                event: viewModel.event(_:)
            )
            
        case .validOTP:
            EmptyView()
        }
    }
}

private extension NavigationBarView.ViewModel {
    
    static func fastPayments(
        action: @escaping () -> Void
    ) -> NavigationBarView.ViewModel {
        
        .init(
            title: "Настройки СБП",
            subtitle: "Система быстрых платежей",
            icon: "sfpBig",
            action: action
        )
    }
    
    convenience init(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            leftItems: [
                BackButtonItemViewModel(action: action)
            ],
            rightItems: [
                IconItemViewModel(
                    icon: Image(icon),
                    style: .large
                )
            ]
        )
    }
}

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .sample)
    }
}

extension FastPaymentsFactory {
    
    static let legacy: Self = .init(
        fastPaymentsViewModel: .legacy({
            
            MeToMeSettingView.ViewModel(
                model: $0,
                newModel: .emptyMock,
                closeAction: $1
            )
        })
    )
    
    static let new: Self = .init(
        fastPaymentsViewModel: .new({
            
            .init(
                initialState: .init(),
                reduce: { state, _ in (state, nil) },
                handleEffect: { _,_ in },
                scheduler: $0
            )
        })
    )
}

extension NavigationStateManager {
    
    static let preview: Self = .init(
        alertReduce: { state, _ in (state, nil) },
        fpsReduce: { state, _ in (state, nil) },
        otpReduce: { state, _,_ in (state, nil) },
        handleOTPEffect: { _,_ in }
    )
}
