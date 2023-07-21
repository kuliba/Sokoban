//
//  PinCodeViewModel.swift
//  
//
//  Created by Andryusina Nataly on 10.07.2023.
//

import Foundation

public class PinCodeViewModel: ObservableObject {
    
    public let title: String
    public let pincodeLength: Int
    public let config: PinCodeView.Config
    
    @Published public var state: CodeState
    
    private(set) var dots: [DotViewModel] = []
    
    public init(
        title: String,
        pincodeLength: Int,
        config: PinCodeView.Config
    ) {
        self.title = title
        self.pincodeLength = pincodeLength
        self.dots = Self.dots("", pincodeLength)
        self.config = config
        self.state = .init(state: .empty, title: title)
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
            //TODO: добавить обработку ошибок для аннимации
        }
        if state.currentStyle == .correct {
            
            //TODO: добавить обработку успешного состояния
        }
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
        config: .defaultConfig
    )
}
