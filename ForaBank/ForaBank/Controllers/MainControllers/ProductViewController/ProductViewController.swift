//
//  ProductViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 31.08.2021.
//

import UIKit

class ProductViewController: UIViewController {

    var products = [GetProductListDatum]()
    var product: GetProductListDatum?
    
    var card = CardCell()
    override func viewDidLoad() {
        super.viewDidLoad()
        var cardModel = CardViewModel(card: self.product!)
        self.navigationItem.setTitle(title: product?.name ?? "", subtitle: product?.numberMasked ?? "")
        title = product?.name ?? ""
        view.backgroundColor = .white
        view.addSubview(card)
        card.anchor(width: 268, height: 172)
        card.center(inView: view)
        card.card = product
    }

}

extension UINavigationItem {
    
    func setTitle(title:String, subtitle:String) {
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 18)
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textAlignment = .center
        two.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.sizeToFit()
        two.sizeToFit()
        
        self.titleView = stackView
    }
}
