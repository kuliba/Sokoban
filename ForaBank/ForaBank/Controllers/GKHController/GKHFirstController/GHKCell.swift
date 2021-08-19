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
    
    func set(viewModel: GKHOperatorsModel) {
        organizationName.text = viewModel.name?.capitalizingFirstLetter()
        innLable.text = viewModel.synonymList.first
        if viewModel.logotypeList.first?.content != "" {
            let dataDecoded : Data = Data(base64Encoded: viewModel.logotypeList.first?.content ?? "", options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            organizationImageView.image = decodedimage
        } else {
            organizationImageView.image = UIImage(named: "GKH")
        }
    }
}
