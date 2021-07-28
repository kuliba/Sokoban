//
//  FullBankInfoListViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 28.07.2021.
//

import UIKit

struct FullBankInfoListViewModel {
    
    //MARK: Color Constants
    private struct Colors {
        static let emeraldColor = UIColor(red: 0.67, green: 0.757, blue: 0.133, alpha: 0.2)
        static let sunflowerColor = UIColor(red: 0.133, green: 0.719, blue: 0.757, alpha: 0.2)
        static let pumpkinColor = UIColor(red: 0.133, green: 0.532, blue: 0.757, alpha: 0.2)
        static let asbestosColor = UIColor(red: 0.133, green: 0.196, blue: 0.757, alpha: 0.2)
        static let amethystColor = UIColor(red: 0.596, green: 0.133, blue: 0.757, alpha: 0.2)
//        static let peterRiverColor = UIColor(red: (52/255), green: (152/255), blue: (219/255), alpha: 1.0)
//        static let pomegranateColor = UIColor(red: (192/255), green: (57/255), blue: (43/255), alpha: 1.0)
    }
    private let index: IndexPath
    
    let bank: BankFullInfoList
    var bankName: String {
        return bank.fullName ?? ""
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
    }
    
    private func updateInitialsColorForIndexPath(_ indexpath: IndexPath) -> UIColor {
        //Applies color to Initial Label
        let colorArray = [Colors.amethystColor, Colors.asbestosColor, Colors.emeraldColor,  Colors.pumpkinColor, Colors.sunflowerColor]
        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
        return colorArray[randomValue]
    }
    
}
