//
//  OrderProcessCardState.swift
//
//
//  Created by Дмитрий Савушкин on 09.12.2024.
//

import Foundation

public typealias LoadFormResult<Confirmation> = Result<Form<Confirmation>, LoadFailure>
public typealias LoadConfirmationResult<Confirmation> = Result<Confirmation, LoadFailure>

public struct State<Confirmation> {
    
    public var isLoading: Bool = false
    public var formResult: LoadFormResult<Confirmation>?
    
    public init(
        isLoading: Bool = false,
        formResult: LoadFormResult<Confirmation>? = nil
    ) {
        self.isLoading = isLoading
        self.formResult = formResult
    }
}

public struct Form<Confirmation> {
    
    public let requestID: String
    public let cardApplicationCardType: String
    public let cardProductExtID: String
    public let cardProductName: String
    
    public var confirmation: LoadConfirmationResult<Confirmation>?
    public var consent = true
    public var messages: Messages
    public var otp: String?
    public var orderCardResponse: OrderCardResponse?

    public init(
        requestID: String,
        cardApplicationCardType: String,
        cardProductExtID: String,
        cardProductName: String,
        confirmation: LoadConfirmationResult<Confirmation>? = nil,
        consent: Bool = true,
        messages: Form<Confirmation>.Messages,
        otp: String? = nil,
        orderCardResponse: OrderCardResponse? = nil
    ) {
        self.requestID = requestID
        self.cardApplicationCardType = cardApplicationCardType
        self.cardProductExtID = cardProductExtID
        self.cardProductName = cardProductName
        self.confirmation = confirmation
        self.consent = consent
        self.messages = messages
        self.otp = otp
        self.orderCardResponse = orderCardResponse
    }
    
    public struct Messages: Equatable {
        
        let description: String
        let icon: String
        let subtitle: String
        let title: String
        public var isOn: Bool
        
        public init(
            description: String,
            icon: String,
            subtitle: String,
            title: String,
            isOn: Bool
        ) {
            self.description = description
            self.icon = icon
            self.subtitle = subtitle
            self.title = title
            self.isOn = isOn
        }
    }
}

public struct LoadFailure: Error, Equatable {
    
    public let message: String
    public let type: FailureType
    
    public init(
        message: String,
        type: FailureType
    ) {
        self.message = message
        self.type = type
    }
    
    public enum FailureType {
        
        case alert, informer
    }
}

public struct OrderCardPayload: Equatable {
    
    public let requestID: String
    public let cardApplicationCardType: String
    public let cardProductExtID: String
    public let cardProductName: String
    public let smsInfo: Bool
    public let verificationCode: String
}

public typealias OrderCardResult = Result<OrderCardResponse, LoadFailure>
public typealias OrderCardResponse = Bool

public extension State {
    
    var consent: Bool { form?.consent ?? false }
    
    var form: Form<Confirmation>? {
        
        get {
            
            guard case let .success(form) = formResult
            else { return nil }
            
            return form
        }
        
        set(newValue) {
            
            guard let newValue, case .success = formResult
            else { return }
            
            formResult = .success(newValue)
        }
    }
    
    var hasConfirmation: Bool {
        
        if case .success = form?.confirmation {
            return true
        } else {
            return false
        }
    }
    
    var isValid: Bool { form?.isValid ?? false } // rename to `canOrder`
    
    var payload: OrderCardPayload? {
        
        guard isValid,
              let form,
              let otp = form.otp
        else { return nil }
        
        return .init(
            requestID: form.requestID,
            cardApplicationCardType: form.cardApplicationCardType,
            cardProductExtID: form.cardProductExtID,
            cardProductName: form.cardProductName,
            smsInfo: form.messages.isOn,
            verificationCode: otp
        )
    }
}

public extension Form {
    
    var isValid: Bool { otp?.count == 6 && consent } // rename to `canOrder`
}
