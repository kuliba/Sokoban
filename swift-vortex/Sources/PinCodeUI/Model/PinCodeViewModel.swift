//
//  PinCodeViewModel.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import Combine
import SwiftUI

public class PinCodeViewModel: ObservableObject {
    
    public let title: String
    public let pincodeLength: Int
    
    @Published public var state: CodeState
    @Published private(set) var phoneNumberState: PhoneNumberState?
    @Published private(set) var mistakes: Int = 0
    var alertMessage: String = ""

    private let getPinConform: (@escaping (PhoneNumberState) -> Void) -> Void

    private(set) var dots: [DotViewModel] = []
    
    public init(
        title: String,
        pincodeLength: Int,
        getPinConfirm: @escaping (@escaping (PhoneNumberState) -> Void) -> Void
    ) {
        self.title = title
        self.pincodeLength = pincodeLength
        self.dots = Self.dots("", pincodeLength)
        self.state = .init(state: .empty, title: title)
        self.getPinConform = getPinConfirm
    }
    
    private func update(with pincodeValue: String, pincodeLength: Int) {
        
        dots = Self.dots(pincodeValue, pincodeLength)
    }
    
    static private func dots(_ pincodeValue: String, _ pincodeLength: Int) -> [DotViewModel] {
        
        return (0..<pincodeLength)
            .map { .init(isFilled: pincodeValue.count > $0) }
    }
    
    public func changeState(codeValue: String) {
        
        switch state.state {
            
        case .empty:
            
            state.updateState(.firstSet(first: codeValue), newCode: codeValue)
            
        case .firstSet:
            
            if codeValue.count == pincodeLength {
                state.updateState(.confirmSet(first: codeValue, second: ""), newCode: "")
            } else {
                
                state.updateState(.firstSet(first: codeValue), newCode: codeValue)
            }
        case .confirmSet(let first, _):
            
            if codeValue.count == pincodeLength {
                
                state.updateState(.checkValue(first: first, second: codeValue), newCode: codeValue)
            } else {
                
                state.updateState(.confirmSet(first: first, second: codeValue), newCode: codeValue)
            }
            
        case .checkValue(let first, _):
            
            if codeValue.count < pincodeLength {
                
                state.updateState(.confirmSet(first: first, second: codeValue), newCode: codeValue)
            }
        }
    }
    
    public func updateView (codeValue: String, codeLength: Int) {
        
        update(
            with: codeValue,
            pincodeLength: codeLength
        )
        changeState(codeValue: codeValue)
    }
    
    public func clearCodeAndUpdateState() {
        
        state.code = ""
        updateView(codeValue: state.code, codeLength: pincodeLength)
    }
    
    public func resetState() {
        
        state.updateState(.empty, newCode: "")
        phoneNumberState = .none
        update(
            with: state.code,
            pincodeLength: pincodeLength
        )
    }
    
    public func confirm() {
        
        updateView(
            codeValue: state.code,
            codeLength: pincodeLength
        )
        
        if needClearDots {
            
            clearCodeAndUpdateState()
        }
        
        if state.currentStyle == .incorrect {
            withAnimation { [weak self] in
                self?.mistakes += 1
            }
        }
        if state.currentStyle == .correct {

            getPinConform { result in
                Task { @MainActor in
                    
                    self.phoneNumberState = result
                }
            }
        }
    }
        
    public var phoneNumber: PhoneNumber? {
        
        switch phoneNumberState {
            
        case .none:
            return nil
        case let .some(.phone(phoneNumber)):
            return phoneNumber
        case .some(.error):
           return nil
        }
    }
    
    public func dismissFullCover(phoneNumber: PhoneNumber?) {
        
        phoneNumberState = nil
    }
    
    public enum PhoneNumberState {
        
        case phone(PhoneNumber)
        case error(Error)
    }
    
    public struct PhoneNumber: Identifiable {
        
        public let value: String
        
        public init(value: String) {
            
            self.value = value
        }
        
        public var id: String { value }
    }
    
    public enum Style {

        case normal
        case incorrect
        case correct
        case printing
    }
    
    public struct DotViewModel: Identifiable {
        
        public let id = UUID()
        public let isFilled: Bool
        
        public init(isFilled: Bool) {
            
            self.isFilled = isFilled
        }
    }
}

extension PinCodeViewModel {
    
    public var needClearDots: Bool {
        
        return state.firstValue.count == pincodeLength && state.confirmValue.isEmpty
    }
}

extension PinCodeViewModel {
    
    static let defaultValue: PinCodeViewModel = .init(
        title: "Введите новый Pin код для карты *4279",
        pincodeLength: 4, 
        getPinConfirm: {_ in }
    )
}
