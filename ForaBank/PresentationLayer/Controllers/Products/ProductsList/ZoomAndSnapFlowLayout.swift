//
//  ZoomAndSnapFlowLayout.swift
//  ForaBank
//
//  Created by  Карпежников Алексей  on 30.03.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {

    var activeDistance: CGFloat = 200 //дистанция на которой происходит анимация 
    var zoomFactor: CGFloat = 0.3 //коэфициетн уменьшения

    func setupFlowLayout(minimumLineSpacing: CGFloat, sizeItem: CGSize, scrollDirection: UICollectionView.ScrollDirection, activeDistance: CGFloat?, zoomFactor: CGFloat?){
        self.minimumLineSpacing = minimumLineSpacing
        self.itemSize = sizeItem
        self.scrollDirection = scrollDirection
        if activeDistance != nil{
            self.activeDistance = activeDistance!
        }
        if zoomFactor != nil{
            self.zoomFactor =  zoomFactor!
        }
    }
    
    override init() {
        super.init()

        //scrollDirection = .horizontal
        //minimumLineSpacing = UIScreen.main.bounds.size.width*0.1
        //itemSize = CGSize(width: UIScreen.main.bounds.size.width*0.6, height: UIScreen.main.bounds.size.height*0.6)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height)/2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width)/2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)

        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

       //Make the cells be zoomed when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance/activeDistance

            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

       //Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width/2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
       //Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}

