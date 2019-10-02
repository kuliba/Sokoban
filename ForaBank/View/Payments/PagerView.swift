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
    @IBOutlet weak var pageControl: FSPageControl!

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
        self.pagerView.itemSize = FSPagerView.automaticSize

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.pageControl.numberOfPages = 3//self.imageNames.count
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }

    }
}

extension PagerView: FSPagerViewDelegate, FSPagerViewDataSource {

    // MARK:- FSPagerView DataSource

    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3 //self.numberOfItems
    }

    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: String(describing: TextFieldPagerViewCell.self), at: index)
        return cell
    }

    // MARK:- FSPagerView Delegate

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
}
