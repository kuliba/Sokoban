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
        
        self.backgroundView?.backgroundColor = .clear // цвет секции
        textLabel?.textColor = .black
        textLabel?.font = UIFont(name: (textLabel?.font.fontName)!, size: 13)
        contentView.backgroundColor = .clear
        //contentView.tintColor = .clear
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
