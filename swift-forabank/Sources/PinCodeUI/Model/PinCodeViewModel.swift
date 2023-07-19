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
    
    public func update(with pincodeValue: String, pincodeLength: Int) {
        
        dots = Self.dots(pincodeValue, pincodeLength)
    }
    
    static private func dots(_ pincodeValue: String, _ pincodeLength: Int) -> [DotViewModel] {
        
        return (0..<pincodeLength)
            .map { .init(isFilled: pincodeValue.count > $0) }
    }
    
    public func changeState(codeValue: String) {
        
        switch state.state {
            
        case .empty:
            
            state.updateState(.firstSet(first: codeValue))
            
        case .firstSet:
            
            if codeValue.count == pincodeLength {
                state.updateState(.confirmSet(first: codeValue, second: ""))
            } else {
                
                state.updateState(.firstSet(first: codeValue))
            }
        case .confirmSet(let first, _):
            
            if codeValue.count == pincodeLength {
                
                state.updateState(.checkValue(first: first, second: codeValue))
            } else {
                
                state.updateState(.confirmSet(first: first, second: codeValue))
            }
            
        case .checkValue(let first, _):
            
            if codeValue.count < pincodeLength {
                
                state.updateState(.confirmSet(first: first, second: codeValue))
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
        
        return state.firstValue.count == pincodeLength && state.secondValue.isEmpty
    }
}

extension PinCodeViewModel {
    
    static let defaultValue: PinCodeViewModel = .init(
        title: "Введите новый Pin код для карты *4279",
        pincodeLength: 4,
        config: .defaultConfig
    )
}
