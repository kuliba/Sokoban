//
//  BankTableViewCell.swift
//  ForaBank
//
//  Created by Mikhail on 19.08.2021.
//

import UIKit

class BankTableViewCell: UITableViewCell {

    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var bankImageView: UIImageView!
    @IBOutlet weak var chekboxImgeView: UIImageView!
    
    static let reuseId = "BankTableViewCell"
    
    var bank: BankFullInfoList!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with bank: BankFullInfoList, and indexPath: IndexPath) {
        self.bank = bank
        var image = UIImage()
        if let imageString = bank.svgImage {
            image = imageString.convertSVGStringToImage()
        } else {
            image = UIImage(named: "BankIcon")!
        }
        bankImageView.image = image
        bankImageView.backgroundColor = bank.svgImage != nil
            ? .clear : updateInitialsColorForIndexPath(indexPath)
        
        bankNameLabel.text = bank.rusName != nil
            ? bank.rusName : bank.fullName
    }
    
    private func updateInitialsColorForIndexPath(_ indexpath: IndexPath) -> UIColor {
        //Applies color to Initial Label
        let colorArray = [Constants.Colors.amethystColor, Constants.Colors.asbestosColor, Constants.Colors.emeraldColor, Constants.Colors.pumpkinColor, Constants.Colors.sunflowerColor]
        let randomValue = (indexpath.row + indexpath.section) % colorArray.count
        return colorArray[randomValue]
    }
}
