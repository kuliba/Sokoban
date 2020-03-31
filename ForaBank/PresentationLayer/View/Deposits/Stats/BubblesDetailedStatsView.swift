//
//  BubblesDetailedStatsView.swift
//  ForaBank
//
//  Created by Sergey on 03/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

protocol BubblesDetailedStatsDelegate: class {
    func numberOfBubbleGroups() -> Int
    func numberOfBubble(forGroupAtIndex index: Int) -> Int
    func radiusOfBubbleView(atIndexPath index: IndexPath) -> CGFloat
    func setUpView(atIndexPath index: IndexPath) -> BubbleDetailedStatsView
    func bubblesMargin() -> Double
}

class BubblesDetailedStatsView: UIView {
    
    // MARK: - properties
    weak var delegate: BubblesDetailedStatsDelegate? = nil {
        didSet {
            numberOfGroups = delegate?.numberOfBubbleGroups() ?? 0
            for i in 0..<numberOfGroups {
                addGroupedView(atIndex: i)
            }
            addSubview(centerView)
        }
    }
    var groupViews: [GroupedBubblesStatsView] = [GroupedBubblesStatsView]()
//    var centralBubbleCenter: CGPoint = CGPoint.zero
    //private properties
    private var numberOfGroups = 0
    private var radiuses: [[CGFloat]]!
    private var startingAngles: [Double] = [0, -90 * Double.pi / 180 , 0]
    private var groupViewsFrames: [CGRect]!
    private var centerView : UIView = {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
//        super.layoutSubviews()
//        print("BubblesDetailedStatsView layoutSubviews \(frame)")
        frame.size = calculateSize()
        setSubviewsFrames()
        
//        super.layoutSubviews()
    }
    
    func centralBubbleCenter() -> CGPoint {
        return CGPoint(x: groupViewsFrames[0].origin.x + groupViews[0].centralBubbleCenter().x, y: 0)
    }
    
    func calculateSize() -> CGSize {
        groupViewsFrames = [CGRect]()
        for (_, g) in groupViews.enumerated() {
            let gframe = g.calculateFrame()
            g.setBubblesOrigins()
            //            print("group \(i) frame \(gframe)")
            //            print("central bubble center \(g.centralBubbleCenter())")
            groupViewsFrames.append(gframe)
        }
        
        var contentSize = CGSize.zero
        //for 3 groups
        if groupViewsFrames.count >= 3 {
            let g2Position = CGPoint.zero
            let g2Frame = CGRect(origin: g2Position, size: groupViewsFrames[2].size)
            groupViewsFrames[2] = g2Frame
            
            let g0Position = CGPoint(
                x: groupViews[2].centralBubbleCenter().x + g2Frame.width - groupViews[0].centralBubbleCenter().x,
                y: groupViews[2].centralBubbleCenter().y + g2Frame.height - groupViews[0].centralBubbleCenter().y)
            let g0Frame = CGRect(origin: g0Position, size: groupViewsFrames[0].size)
            groupViewsFrames[0] = g0Frame
            
            let g1Position = CGPoint(
                x: g0Position.x + groupViews[0].centralBubbleCenter().x + groupViewsFrames[1].size.width - groupViews[1].centralBubbleCenter().x - 25,
                y: g0Position.y + groupViews[0].centralBubbleCenter().y - groupViewsFrames[1].size.height - groupViews[1].centralBubbleCenter().y + 25)
            let g1Frame = CGRect(origin: g1Position, size: groupViewsFrames[1].size)
            groupViewsFrames[1] = g1Frame
            
            var maxX: CGFloat = 0
            var maxY: CGFloat = 0
            for g in groupViewsFrames {
                maxX = maxX > g.origin.x + g.width ? maxX : g.origin.x + g.width
                maxY = maxY > g.origin.y + g.height ? maxY : g.origin.y + g.height
            }
            contentSize = CGSize(width: maxX, height: maxY)
//            centralBubbleCenter = CGPoint(x: groupViewsFrames[0].origin.x + groupViews[0].centralBubbleCenter().x, y: 0)
        }
        return contentSize
    }
    
    func setSubviewsFrames() {
        //setup for 3 groups
        groupViews[2].frame = groupViewsFrames[2]
        groupViews[0].frame = groupViewsFrames[0]
        groupViews[1].frame = groupViewsFrames[1]
    }
    
    func calculateScales(forXOffset offset: CGFloat, maxOffset: CGFloat) {
//        print("!!!calculateScales for offset \(offset)")
//        print("centralBubbleCenter.x \(centralBubbleCenter().x)")

        var newGroupViewsFrames = [CGRect]()
        for g in groupViews {
//            print("!-! g before \(g.frame)")
//            print("g.frame.origin.x \(g.frame.origin.x)")
            g.calculateScales(forXOffset: offset, maxOffset: maxOffset, fromX: centralBubbleCenter().x-g.frame.origin.x)
            let gframe = g.calculateFrame()
            g.setBubblesOrigins()
            g.setSubviewsSizes()
            g.layoutSubviews()
            newGroupViewsFrames.append(gframe)
//            print("!-! g \(gframe)")
        }
//        print("!-! g \(newGroupViewsFrames[0].size)")
//        groupViewsFrames = newGroupViewsFrames
//        centerView.frame = CGRect(x: centralBubbleCenter().x-0.5, y: 0, width: 1, height: frame.height)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: - private methods
private extension BubblesDetailedStatsView {
    
    func addGroupedView(atIndex i: Int) {
        let numOfGroupedBubbles =  delegate?.numberOfBubble(forGroupAtIndex: i) ?? 0
        var groupRadiuses = [CGFloat]()
        for j in 0..<numOfGroupedBubbles {
            let r = delegate!.radiusOfBubbleView(atIndexPath: IndexPath(item: j, section: i))
            groupRadiuses.append(r)
        }
        let m = delegate!.bubblesMargin()
        let g = GroupedBubblesStatsView(
            withCount: numOfGroupedBubbles,
            radiuses: groupRadiuses,
            margin: m,
            autoDistribution: false,
            clockwise: true,
            startingAngle: startingAngles[i],
            index: i)
        g.delegate = delegate
//        g.backgroundColor = UIColor(
//            red: CGFloat(i)/CGFloat(numOfGroupedBubbles),
//            green: CGFloat(i)/CGFloat(numOfGroupedBubbles),
//            blue: 0.5, alpha: 1)
        //(withCount: numOfGroupedBubbles, radiuses: groupRadiuses, margin: m)
        groupViews.append(g)
        addSubview(g)
    }
    
    
}
