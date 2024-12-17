//
//  GHKCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.07.2021.
//

import UIKit

class GHKCell: UITableViewCell {
    
    static let reuseId = "GHKCell"
    @IBOutlet weak var organizationName: UILabel!
    @IBOutlet weak var innLable: UILabel!
    @IBOutlet weak var organizationImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        organizationImageView.image = nil
    }
    
    func set(item: CustomGroup) {
        organizationName.text = item.name.uppercased()
        organizationImageView.image = UIImage(named: "GKH")
        if item.op == nil && item.childsOperators.count > 0 {
            let op = item.childsOperators[0]
            innLable.text = op.synonymList.first
            if let svgImg = op.logotypeList.first?.svgImage {
                let image = svgImg.convertSVGStringToImage()
                organizationImageView.image = image
            } else {
                organizationImageView.image = UIImage(named: "GKH")
            }
        } else {
            innLable.text = item.op?.synonymList.first
            if let svgImg = item.op?.logotypeList.first?.svgImage {
                //let dataDecoded : Data = Data(base64Encoded: viewModel.logotypeList.first?.content ?? "", options: .ignoreUnknownCharacters)!
                //let decodedimage = UIImage(data: dataDecoded)
                let image = svgImg.convertSVGStringToImage()
                organizationImageView.image = image
            } else {
                organizationImageView.image = UIImage(named: "GKH")
            }
        }
    }
}
