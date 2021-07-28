//
//  GHKCell.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.07.2021.
//

import UIKit
import SVGKit

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
    
    func set(viewModel: GetAnywayOperatorsListDatum) {
        organizationName.text = viewModel.name?.capitalizingFirstLetter()
        organizationImageView.image = UIImage(named: "GKH")
        innLable.text = viewModel.synonymList?.first
//        if viewModel.logotypeList?.first?.content != "" {
//        organizationImageView.image = convertSVGStringToImage(viewModel.logotypeList?.first?.content ?? "")
//        } else {
//            organizationImageView.image = UIImage(named: "GKH")
//        }
    }
    
    func convertSVGStringToImage(_ string: String) -> UIImage {
        let imageData = Data(string.utf8)
        let imageSVG = SVGKImage(data: imageData)
        let image = imageSVG?.uiImage ?? UIImage()
        return image
    }

}
