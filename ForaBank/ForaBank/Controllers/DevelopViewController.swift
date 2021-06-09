//
//  DevelopViewController.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import UIKit

class DevelopViewController: UIViewController {

    let imageView = UIImageView(image: UIImage(named: "ErrorIcon"))
    
    let titleLabel = UILabel(
        text: "В разработке",
        font: .boldSystemFont(ofSize: 18), color: .black)
    
    let subTitleLabel = UILabel(
        text: "Этот функционал рейчас в разработке, мы скоро его дабавим",
        font: .systemFont(ofSize: 14), color: .black)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        
        titleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .center
        
        imageView.setDimensions(height: 250, width: 250)
        imageView.centerX(inView: view,
                          topAnchor: view.safeAreaLayoutGuide.topAnchor,
                          paddingTop: 22)
        
        titleLabel.anchor(left: view.leftAnchor, right: view.rightAnchor,
                          paddingLeft: 20, paddingRight: 20)
        titleLabel.centerX(inView: view,
                           topAnchor: imageView.bottomAnchor, paddingTop: 44)
        
        subTitleLabel.centerX(inView: view,
                           topAnchor: titleLabel.bottomAnchor, paddingTop: 16)
        subTitleLabel.anchor(left: view.leftAnchor, right: view.rightAnchor,
                             paddingLeft: 20, paddingRight: 20)
    }

}
