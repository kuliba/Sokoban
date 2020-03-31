//
//  GroupedBubblesStatsView.swift
//  ForaBank
//
//  Created by Sergey on 03/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class GroupedBubblesStatsView: UIView {

    // MARK: - properties
    var bubbleViews: [BubbleDetailedStatsView] = [BubbleDetailedStatsView]()
    var baseOffset: CGPoint = CGPoint.zero
    weak var delegate: BubblesDetailedStatsDelegate? = nil {
        didSet {
            addBubbleViews()
            _ = calculateFrame()
            setBubblesFrames()
            setBubblesOrigins()
        }
    }
    
    //init properties
    private var count = 0
    private var initRadiuses: [CGFloat]!
    private var bubbleMargin: Double!
    private var autoDistribution: Bool!
    private var clockwise: Bool!
    private var startingAngle: Double!
    private var groupIndex: Int!

    //for calculate positions and frame
    private var minX: CGFloat = 0
    private var minY: CGFloat = 0
    private var maxX: CGFloat = 0
    private var maxY: CGFloat = 0
    private var viewFrames = [CGRect]()
    private var isSized = false
    private var distances = [Double]()
    private var resizeScales = [CGFloat]()
    private var centerView : UIView = {
        let v = UIView()
        v.backgroundColor = .green
        return v
    }()
    private var baseScales: [CGFloat]!
    
    //MARK: - init
    convenience init(withCount c: Int, radiuses: [CGFloat], margin: Double, autoDistribution: Bool, clockwise: Bool, startingAngle: Double, index: Int) {
        self.init(frame: CGRect.zero)
        count = c
        initRadiuses = radiuses
        bubbleMargin = margin
        self.autoDistribution = autoDistribution
        self.clockwise = clockwise
        self.startingAngle = startingAngle
        groupIndex = index
        resizeScales = Array.init(repeating: 1, count: count)
        baseScales = Array.init(repeating: 1, count: count)

//        addBubbleViews()
//        calculateFrame()
//        setBubblesFrames()
//        setBubblesOrigins()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - public methods
    func centralBubbleCenter() -> CGPoint {
//        print("centralBubbleCenter viewFrame[0] \(viewFrames[0])")
//        print("bubbleViews[0].frame \(bubbleViews[0].frame)")
        return CGPoint(
            x: viewFrames[0].origin.x + viewFrames[0].size.width/2,
            y: viewFrames[0].origin.y + viewFrames[0].size.height/2)
    }
    
    func calculateFrame() -> CGRect {
//        print("GroupedBubblesStatsView calculateFrame")
        calculateFrames()
//        for i in 0..<count {
//            print("viewFrames \(i) - \(viewFrames[i])")
//        }
        transferToNormalCoordinates()
//        print("calculateFrames")
//        for i in 0..<count {
//            print("viewFrames \(i) - \(viewFrames[i])")
//        }
        return CGRect(x: -centralBubbleCenter().x, y: -centralBubbleCenter().y, width: maxX - minX, height: maxY - minY)
    }
    
    func setBubblesOrigins() {
        for i in 0..<count {
            bubbleViews[i].frame.origin.x = viewFrames[i].origin.x
            bubbleViews[i].frame.origin.y = viewFrames[i].origin.y
        }
    }
    func setSubviewsSizes() {
        for i in 0..<count {
            bubbleViews[i].scale = resizeScales[i]
        }
    }
    func setBubblesFrames() {
        for i in 0..<count {
            bubbleViews[i].frame = viewFrames[i]
        }
    }
    
    func calculateScales(forXOffset offset: CGFloat, maxOffset: CGFloat, fromX: CGFloat) {
//        print("calculateScales for offset \(offset) maxOffset \(maxOffset) fromX \(fromX)")
        centerView.frame = CGRect(x: fromX+offset-0.5, y: 0, width: 1, height: frame.height)
        for i in 0..<count {
            let center = viewFrames[i].origin.x + viewFrames[i].width/2
//            print("center \(center)")
            let toSuperViewCenter = Double( fromX - center )
//            print("toSuperViewCenter \(toSuperViewCenter)")
            let toSuperViewCenterWithOffset = toSuperViewCenter + Double( offset )
//            print("toSuperViewCenterWithOffset \(toSuperViewCenterWithOffset)")
            
            let _ : Double = fabs( toSuperViewCenterWithOffset - Double ( center ) )
//            print("diff \(diff)")

            var scale: Double = 1
//            if toSuperViewCenterWithOffset != 0 {
                scale = 1.0 - fabs(toSuperViewCenterWithOffset) / Double(4 * maxOffset)
//            }
//            print("scale \(scale)")
//            print("baseScales[\(groupIndex)][\(i)] \(baseScales[i])")
            resizeScales[i] = CGFloat(scale)
            if !isSized {
                baseScales[i] = CGFloat(scale)
                isSized = true
            }
            bubbleViews[i].transform = CGAffineTransform(scaleX: resizeScales[i] / baseScales[i] , y: resizeScales[i] / baseScales[i] )
//            bubbleViews[i].layoutSubviews()
//            bubbleViews[i].layer.anchorPoint = CGPoint(x: 0, y: 0)
//            let t = CGAffineTransform(scaleX: scale, y: scale)
//            bubbleViews[i].transform = t
//            bubbleViews[i].layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
//        print(resizeScales[0])
    }
    
    override func layoutSubviews() {
//        super.layoutSubviews()
//        print("GroupedBubblesStatsView layoutSubviews \(frame)")
//        for i in 0..<count {
//            print("\(i) - \(bubbleViews[i])")
//        }
//        print(subviews)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

private extension GroupedBubblesStatsView {
    func addBubbleViews() {
        for i in 0..<count {
            let view = delegate!.setUpView(atIndexPath: IndexPath(item: i, section: groupIndex))
//            view.backgroundColor = .blue
            view.layer.cornerRadius = initRadiuses[i]
            addSubview(view)
            bubbleViews.append(view)
//            bubblesDelegate?.setup(bubbleView: view, atIndex: i)
        }
//        addSubview(centerView)
    }
    
    func calculateFrames() {
//                print("calculateFrames \(initRadiuses[0]) \(resizeScales[0]) \(baseScales[0]) ")
        let centralViewRadius = Double(initRadiuses[0] * resizeScales[0] / baseScales[0] )
//        print("centralViewRadius \(centralViewRadius)")
        var viewAlphas = [Double]()
        var sumOfAlphas: Double = 0
        distances = [0]
        for i in 1..<count {
            let viewRadius = Double(initRadiuses[i] * resizeScales[i] / baseScales[i] )
            //максимальный требуемый угол для размещения соседнего баббла обозначим maxAlpha
            //чтобы его посчитать воспользуемся формулой 2 * asin( (viewRadius + bubbleMargin) / (centralViewRadius + viewRadius + 2*bubbleMargin) )
            //            print("viewRadius \(viewRadius)")
            distances.append(centralViewRadius + viewRadius + 2*bubbleMargin)
            //            print("beetween centers \(radiuses[i-1])")
            let maxAlpha = 2 * asin( (viewRadius + bubbleMargin) / (distances[i] ) )
            //            print("alpha_i \(maxAlpha)")
            viewAlphas.append(maxAlpha)
//            if clockwise {
//                sumOfAlphas -= maxAlpha
//            } else {
                sumOfAlphas += maxAlpha
//            }
        }
        //теперь нужно пропорционально увеличить или уменьшить альфы чтобы их сумма была = 360 * 180 / Double.pi
        //коэффициент умножения назовем lambda
        //        print(360 * Double.pi / 180)
//        let fullCirlce: Double = clockwise ? -360 : 360
        let lambda = 360 * Double.pi / (180  * sumOfAlphas ) // для равномерного распределения
        //        let lambda = ((360 * Double.pi) / 180 - viewAlphas[0] - viewAlphas[1] - viewAlphas[4]) / (viewAlphas[2] + viewAlphas[3])
        
        var centeredPositions = [CGPoint]()
        centeredPositions.append(CGPoint(x: 0, y: 0))
        var angleOffset: Double = startingAngle
        
        viewFrames = [CGRect(x: -centralViewRadius,
                             y: -centralViewRadius,
                             width: centralViewRadius*2,
                             height: centralViewRadius*2)]
        
        minX = viewFrames[0].origin.x
        minY = viewFrames[0].origin.y
        maxX = viewFrames[0].origin.x + viewFrames[0].width
        maxY = viewFrames[0].origin.y + viewFrames[0].height
        
        for i in 1..<count {
            let viewRadius = Double(initRadiuses[i] * resizeScales[i] / baseScales[i] )
            viewAlphas[i-1] *= autoDistribution ? lambda : 1
            
            let newR = (viewRadius + bubbleMargin) / sin(viewAlphas[i-1] / 2)
            distances[i] = newR < distances[i] ? distances[i] : newR
            angleOffset += i==1 ? 0 : (clockwise ? -1 : 1) * viewAlphas[i-1] / 2
            //let positionAngle: Double = i==1 ? 0 : viewAlphas[i-1] / 2 + angleOffset
            let cx = cos(angleOffset) * distances[i]
            let cy = sin(angleOffset) * distances[i]
            angleOffset += (clockwise ? -1 : 1) * viewAlphas[i-1] / 2
            
            let viewFrame = CGRect(x: cx-viewRadius,
                                   y: -cy-viewRadius,
                                   width: viewRadius*2,
                                   height: viewRadius*2)
            viewFrames.append(viewFrame)

            minX = minX < viewFrames[i].origin.x ? minX : viewFrames[i].origin.x
            minY = minY < viewFrames[i].origin.y ? minY : viewFrames[i].origin.y
            maxX = maxX > viewFrames[i].origin.x + viewFrames[i].width ?
                maxX : viewFrames[i].origin.x + viewFrames[i].width
            maxY = maxY > viewFrames[i].origin.y + viewFrames[i].height ?
                maxY : viewFrames[i].origin.y + viewFrames[i].height
        }
    }
    
    func transferToNormalCoordinates() {
        for i in 0..<count {
            viewFrames[i].origin.x = viewFrames[i].origin.x - minX
            viewFrames[i].origin.y = viewFrames[i].origin.y - minY
        }
    }
}
