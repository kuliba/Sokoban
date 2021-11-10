//
//  QRScanerInfoView.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.11.2021.
//

import UIKit

class QRScanerInfoView: UIView {
    
    var clouseButton: UIButton {
        let button = UIButton()
        button.setTitle("Закрыть", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.black, for: .normal)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        return button
    }
    
    var infoImage: UIImageView {
        let imageName = "qrInfoImage"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 88.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 88.0).isActive = true
        return imageView
    }
    
    var infoLable: UILabel {
        let lable = UILabel()
        let lableString = "Сканировать QR-код"
        lable.text = lableString
        lable.font = UIFont.boldSystemFont(ofSize: 20)
        lable.textAlignment = .center
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return lable
    }
    
    var infoLable_1: UILabel {
        let lable = UILabel()
        let lableString = "Наведите камеру телефона на QR-код и приложение автоматически его считает."
        lable.text = lableString
        lable.font = UIFont.systemFont(ofSize: 15)
        lable.textAlignment = .center
        lable.numberOfLines = 0
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return lable
    }
    
    var infoLable_2: UILabel {
        let lable = UILabel()
        let lableString = "Перед оплатой проверьте, что все поля заполнены правильно."
        lable.text = lableString
        lable.font = UIFont.systemFont(ofSize: 15)
        lable.textAlignment = .center
        lable.numberOfLines = 0
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return lable
    }
    
    var infoLable_3: UILabel {
        let lable = UILabel()
        let lableString = "Чтобы оплатить квитанцию, сохраненную в телефоне, откройте ее с помощью кнопки \"Из файла\" и отсканируйте QR-код."
        lable.text = lableString
        lable.font = UIFont.systemFont(ofSize: 15)
        lable.textAlignment = .center
        lable.numberOfLines = 0
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        return lable
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setNeedsUpdateConstraints
        let stackView = UIStackView()
        stackView.axis          = .vertical
        stackView.distribution  = .fillProportionally
        stackView.alignment     = .fill
        stackView.spacing       = 5

        stackView.addArrangedSubview(clouseButton)
        stackView.addArrangedSubview(infoImage)
        stackView.addArrangedSubview(infoLable)
        stackView.addArrangedSubview(infoLable_1)
        stackView.addArrangedSubview(infoLable_2)
        stackView.addArrangedSubview(infoLable_3)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

