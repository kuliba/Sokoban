//
//  FullBankInfoListViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 28.07.2021.
//

import UIKit

struct FullBankInfoListViewModel {
    

    private let index: IndexPath
    
    let bank: BankFullInfoList
    var bankName: String {
        
        if self.check(bank.fullName ?? "") {
            let bankFullName: String = bank.fullName ?? ""
            let fullNameArr = bankFullName.components(separatedBy: "\"")
            let shortName: String = fullNameArr[1]
            return shortName//.capitalizingFirstLetter()
        } else {
            return bank.fullName ?? ""
        }
        
    }
    var bicNumber: String {
        return bank.bic ?? ""
    }
    
    var bankImage: UIImage {
        if let imageString = bank.svgImage {
            return imageString.convertSVGStringToImage()
        } else {
            return UIImage(named: "BankIcon")!
        }
    }
    
    var backgroundColor: UIColor {
        if bank.svgImage != nil {
            return .clear
        } else {
            return updateInitialsColorForIndexPath(index)
        }
    }
    
    var cornerRadius: CGFloat {
        if bank.svgImage != nil {
            return 0
        } else {
            return 20
        }
    }
    
    init(bank: BankFullInfoList, index: IndexPath) {
        self.bank = bank
        self.index = index
//        let name = "ПАО \"БЕСТ ЭФФОРТС БАНК\""
//        print("bankName \(bank.fullName) have /: ", self.check(bank.fullName ?? ""))
    }
    
    private func updateInitialsColorForIndexPath(_ indexpath: IndexPath) -> UIColor {
        //Applies color to Initial Label
        let colorArray = [Constants.Colors.amethystColor, Constants.Colors.asbestosColor, Constants.Colors.emeraldColor, Constants.Colors.pumpkinColor, Constants.Colors.sunflowerColor]
        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
        return colorArray[randomValue]
    }
    
    private func check(_ givenString: String) -> Bool {
        return givenString.range(of: "\"", options: .regularExpression) != nil
    }
    
}
