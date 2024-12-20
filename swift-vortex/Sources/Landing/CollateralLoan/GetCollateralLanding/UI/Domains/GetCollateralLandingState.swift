//
//  GetCollateralLandingState.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import Foundation

public struct GetCollateralLandingState: Equatable {
    
    var bottomSheet: BottomSheet?
    let product: Product
}

extension GetCollateralLandingState {

    public struct BottomSheet: Equatable, Identifiable {
        
        public let id = UUID()
        public let sheetType: SheetType
        
        public enum SheetType: Equatable {
            
            case periods([Period])
            case collaterals([Collateral])
        }
        
        public struct Item: Equatable, Identifiable {
            
            public let id: String
            let termMonth: UInt?
            let icon: String?
            let title: String
        }
    }
}

public extension GetCollateralLandingState {
    
    typealias Product = GetCollateralLandingProduct
    typealias Period = GetCollateralLandingProduct.Calc.Rate
    typealias Collateral = GetCollateralLandingProduct.Calc.Collateral
}
