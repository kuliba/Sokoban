//
//  ExpactableHeaderView.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 20.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpactableHeaderView, section: Int)
}

class ExpactableHeaderView: UITableViewHeaderFooterView {

    var delegate: ExpandableHeaderViewDelegate?
    var section: Int?
    
    func setup(withTitle title:String, section: Int, delegate: ExpandableHeaderViewDelegate){
        self.delegate = delegate
        self.section = section
        self.textLabel?.text = title
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        self.backgroundView?.backgroundColor = .clear // цвет секции
        textLabel?.textColor = .black
        textLabel?.font = UIFont(name: "Roboto", size: 15)//UIFont.boldSystemFont(ofSize: 13)
        contentView.backgroundColor = .white
        
        //self.backgroundView = UIImageView()
        
//        let imageSectionOn = UIImageView()
//        imageSectionOn.contentMode = .scaleAspectFit
//        imageSectionOn.image = UIImage(named: "hidden")
//        let framImage = CGRect(x: 0, y: 0, width: 13, height: 13)
//        imageSectionOn.frame = framImage
//        //self.backgroundView = imageSectionOn
//        self.addSubview(imageSectionOn)
//
//        imageSectionOn.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint(item: imageSectionOn, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: imageSectionOn, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 13).isActive = true
//        NSLayoutConstraint(item: imageSectionOn, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 13).isActive = true
//        NSLayoutConstraint(item: imageSectionOn, attribute: .trailing, relatedBy: .equal, toItem: self.backgroundView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        
        

    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectHeaderAction(gesterRecognizer: UITapGestureRecognizer){
        let cell = gesterRecognizer.view as! ExpactableHeaderView
        guard let sect = cell.section else{
            print("Error in selectHeaderAction")
            return}
        delegate?.toggleSection(header: self, section: sect)
    }
    
}
