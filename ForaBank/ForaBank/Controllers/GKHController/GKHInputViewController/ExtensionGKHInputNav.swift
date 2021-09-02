//
//  ExtensionGKHInputNav.swift
//  ForaBank
//
//  Created by Константин Савялов on 27.08.2021.
//

import UIKit

extension GKHInputViewController {
    
    func setupNavBar() {
        
        let operatorsName = operatorData?.name ?? ""
        let inn = operatorData?.synonymList.first ?? ""
        self.navigationItem.titleView = set_Title(title: operatorsName, subtitle: "ИНН " +  inn )
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        
        if !(operatorData?.logotypeList.isEmpty)!  {
            let dataDecoded : Data = Data(base64Encoded: operatorData?.logotypeList.first?.content ?? "", options: .ignoreUnknownCharacters)!
            
            let decodedimage = UIImage(data: dataDecoded)
            imageView.image = decodedimage
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
            
        } else {
            imageView.image = UIImage(named: "GKH")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
        }
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
    }
    
    func set_Title(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width),  height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)

        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width

        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }

        return titleView
    }

}
