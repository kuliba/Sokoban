//
//  GetCollateralLandingDomain+State.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import Foundation

extension GetCollateralLandingDomain {
    
    public struct State: Equatable {
        
        var isLoading = false
        var result: Result?
        var bottomSheet: BottomSheet?
        public let landingID: String
        
        public init(
            isLoading: Bool = false,
            result: Result? = nil,
            bottomSheet: BottomSheet? = nil,
            landingID: String
        ) {
            self.isLoading = isLoading
            self.result = result
            self.bottomSheet = bottomSheet
            self.landingID = landingID
        }
    }
}

extension GetCollateralLandingDomain.State {

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

extension GetCollateralLandingDomain.State {
    
    var product: Product? {

        try? result?.get()
    }
}

public extension GetCollateralLandingDomain.State {
    
    typealias Product = GetCollateralLandingProduct
    typealias Period = GetCollateralLandingProduct.Calc.Rate
    typealias Collateral = GetCollateralLandingProduct.Calc.Collateral
}
