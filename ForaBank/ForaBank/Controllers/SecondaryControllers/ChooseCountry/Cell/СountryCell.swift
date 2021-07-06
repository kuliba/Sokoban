//
//  СountryCell.swift
//  MyMusic
//
//  Created by Михаил on 03.12.2019.
//  Copyright © 2019 Михаил Колотилин. All rights reserved.
//

import UIKit
import SVGKit

class СountryCell: UITableViewCell {
    
    static let reuseId = "СountryCell"
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        countryImageView.image = nil
    }
    
    func set(viewModel: CountriesList) {
        countryNameLabel.text = viewModel.name?.capitalizingFirstLetter()
        countryImageView.image = convertSVGStringToImage(viewModel.svgImage ?? "")
    }
    
    func convertSVGStringToImage(_ string: String) -> UIImage {
        let imageData = Data(string.utf8)
        let imageSVG = SVGKImage(data: imageData)
        let image = imageSVG?.uiImage ?? UIImage()
        return image
    }
    
}
