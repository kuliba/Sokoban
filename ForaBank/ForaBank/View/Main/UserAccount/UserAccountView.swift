//
//  UserAccountView.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import LandingUIComponent
import SwiftUI
import Presentation
import ManageSubscriptionsUI
import SearchBarComponent

struct UserAccountView: View {
    
    @ObservedObject var viewModel: UserAccountViewModel
        
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 20) {
                
                avatarView
                
                ForEach(viewModel.sections, content: sectionView)
                
                viewModel.exitButton.map {
                    
                    AccountCellFullButtonView(viewModel: $0)
                        .padding(.horizontal, 20)
                }
                
                viewModel.deleteAccountButton.map {
                    
                    AccountCellFullButtonWithInfoView(viewModel: $0)
                        .padding(.horizontal, 20)
                }
                
                viewModel.appVersionFull.map {
                    
                    Text($0)
                        .foregroundColor(Color.textPlaceholder)
                        .lineLimit(1)
                        .font(.textH4R16240())
                }
            }
            .navigationDestination(
                item: $viewModel.link,
                content: destinationView(link:)
            )
        }
        .sheet(item: $viewModel.sheet, content: sheetView)
        .bottomSheet(item: $viewModel.bottomSheet, content: bottomSheetView)
        .alert(item: $viewModel.alert, content: Alert.init(with:))
        .textfieldAlert(alert: $viewModel.textFieldAlert)
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
    private func destinationView(
        link: UserAccountViewModel.Link
    ) -> some View {
        
        switch link {
            
        case let .userDocument(userDocumentViewModel):
            UserDocumentView(viewModel: userDocumentViewModel)
            
        case let .fastPaymentSettings(meToMeSettingsViewModel):
            MeToMeSettingView(viewModel: meToMeSettingsViewModel)
                .navigationBarBackButtonHidden(false)
                .navigationBarTitle("", displayMode: .inline)
            
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
    
    @ViewBuilder
    private func sheetView(
        sheet: UserAccountViewModel.Sheet
    ) -> some View {
        
        switch sheet.sheetType {
            
        case let .userDocument(userDocumentViewModel):
            UserDocumentView(viewModel: userDocumentViewModel)
        }
    }
    
    @ViewBuilder
    private func bottomSheetView(
        sheet: UserAccountViewModel.BottomSheet
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

struct UserAccountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserAccountView(viewModel: .sample)
    }
}

extension UserAccountViewModel {
    
    static let sample = UserAccountViewModel(
        navigationBar: .sample,
        avatar: .init(
            image: Image("imgMainBanner2"),
            //image: nil,
            action: {
                //TODO: set action
            }),
        sections:
            [UserAccountContactsView.ViewModel.contact,
             UserAccountDocumentsView.ViewModel.documents,
             UserAccountPaymentsView.ViewModel.payments,
             UserAccountSecurityView.ViewModel.security
            ],
        exitButton: .init(
            icon: .ic24LogOut,
            content: "Выход из приложения",
            action: {
                //TODO: set action
            }),
        deleteAccountButton: .init(
            icon: .ic24UserX, content: "Удалить учетную запись",
            infoButton: .init(icon: .ic24Info, action: { }),
            action: {}
        )
    )
}
