//
//  UserAccountRoute.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.01.2024.
//

import Combine
import FastPaymentsSettings
import OTPInputComponent
import RxViewModel
import SwiftUI
import UIPrimitives

struct UserAccountRoute {
    
    var alert: AlertModelOf<UserAccountEvent>?
    var bottomSheet: BottomSheet?
    var informer: Informer?
    var link: Link?
    var sheet: Sheet?
    var spinner: SpinnerView.ViewModel?
    var textFieldAlert: AlertTextFieldView.ViewModel?
}

extension UserAccountRoute {
    
    struct Informer {
        
        let icon: Icon
        let message: String
        
        enum Icon {
            
            case failure, success
        }
    }
    
    enum Link: Hashable, Identifiable {
        
        case userDocument(UserDocumentViewModel)
        case fastPaymentSettings(FastPaymentSettings)
        case deleteUserInfo(DeleteAccountView.DeleteAccountViewModel)
        case imagePicker(ImagePickerViewModel)
        case managingSubscription(SubscriptionsViewModel)
        case successView(PaymentsSuccessViewModel)
        
        enum FastPaymentSettings {
            
            case legacy(MeToMeSettingView.ViewModel)
            case new(FPSRoute)
            
            var id: ID {
                switch self {
                case .legacy: return .legacy
                case .new:    return .new
                }
            }
            
            enum ID {
                
                case legacy, new
            }
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case userDocument(UserDocumentViewModel)
        }
    }
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case deleteInfo(UserAccountExitInfoView.ViewModel)
            case inn(UserAccountDocumentInfoView.ViewModel)
            case camera(UserAccountPhotoSourceView.ViewModel)
            case avatarOptions(OptionsButtonsViewComponent.ViewModel)
            case imageCapture(ImageCaptureViewModel)
            case sbpay(SbpPayViewModel)
        }
    }
}

extension UserAccountRoute.Link {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id.hashValue)
    }
    
    var id: Case {
        
        switch self {
        case .userDocument:
            return .userDocument
            
        case let .fastPaymentSettings(fastPaymentSettings):
            switch fastPaymentSettings {
            case .legacy:
                return .fastPaymentSettings(.legacy)
                
            case .new:
                return .fastPaymentSettings(.new)
            }
            
        case .deleteUserInfo:
            return .deleteUserInfo
            
        case .imagePicker:
            return .imagePicker
            
        case .managingSubscription:
            return .managingSubscription
            
        case .successView:
            return .successView
        }
    }
    
    enum Case: Hashable {
        
        case userDocument
        case fastPaymentSettings(FastPaymentSettings)
        case deleteUserInfo
        case imagePicker
        case managingSubscription
        case successView
        
        enum FastPaymentSettings {
            
            case legacy, new
        }
    }
}

extension UserAccountRoute {
    
    typealias FastPaymentsSettingsViewModel = RxViewModel<FastPaymentsSettingsState, FastPaymentsSettingsEvent, FastPaymentsSettingsEffect>
    
    typealias FPSRoute = GenericRoute<FastPaymentsSettingsViewModel, UserAccountRoute.FPSDestination, Never, AlertModelOf<UserAccountEvent>>
}

extension UserAccountRoute {
    
    enum FPSDestination: Equatable, Identifiable {
        
        case confirmSetBankDefault(TimedOTPInputViewModel, AnyCancellable)//(phoneNumberMask: String)
        
        public var id: Case {
            
            switch self {
            case .confirmSetBankDefault:
                return .confirmSetBankDefault
            }
        }
        
        public enum Case {
            
            case c2BSub
            case confirmSetBankDefault
        }
    }
}

// MARK: - Hashable Conformance

extension UserAccountRoute.FPSDestination: Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.confirmSetBankDefault(lhs, _), .confirmSetBankDefault(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .confirmSetBankDefault(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
}
