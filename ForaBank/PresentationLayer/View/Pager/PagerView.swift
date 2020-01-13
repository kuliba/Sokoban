//
//  PagerView.swift
//  ForaBank
//
//  Created by Бойко Владимир on 01/10/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit
import FSPagerView

class PagerView: UIView {

    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            pageControl.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            pageControl.setFillColor(.gray, for: .normal)
            pageControl.setFillColor(.commonRed, for: .selected)
        }
    }
    


    var configurations = [ICellConfigurator]()
    var currentIndex: Int {
        return pagerView.currentIndex
    }

    // MARK: - Live Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    

    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: PagerView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.pagerView.register(UINib(nibName: String(describing: TextFieldPagerViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: TextFieldPagerViewCell.self))
        self.pagerView.register(UINib(nibName: String(describing: MenuPagerViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: MenuPagerViewCell.self))
        self.pagerView.register(UINib(nibName: String(describing: DropDownPagerViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: DropDownPagerViewCell.self))

        self.pagerView.itemSize = FSPagerView.automaticSize
    }

    func setConfig(config: [ICellConfigurator]) {
        configurations = config
        pageControl.numberOfPages = configurations.count
        pagerView.reloadData()
    }
}

extension PagerView: FSPagerViewDelegate, FSPagerViewDataSource {

    // MARK:- FSPagerView DataSource

    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return configurations.count
    }

    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let config = configurations[index]

        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: type(of: config).reuseId, at: index)
        config.configure(cell: cell)

        return cell
    }

    // MARK: - FSPagerViewDelegate

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }

    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        self.endEditing(true)
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
}
