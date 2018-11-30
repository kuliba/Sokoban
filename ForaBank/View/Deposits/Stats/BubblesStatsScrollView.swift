//
//  StatsBubbleScrollView.swift
//  ForaBank
//
//  Created by Sergey on 30/11/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

protocol BubblesStatsDelegate {
    func setup(bubbleView: BubbleStatsView, atIndex index: Int)
    func numberOfBubbleViews() -> Int
    func radiusOfBubbleView(atIndex index: Int) -> CGFloat
}

class BubblesStatsScrollView: UIScrollView {
    //MARK: - properties
    let contentView: UIView = {
        let v = UIView()
        return v
    }()
    var bubblesDelegate: BubblesStatsDelegate? = nil {
        didSet {
            addBubbleViews()
        }
    }
    var bubbleMargin: Double = 3
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    var bubbleViews: [BubbleStatsView] = [BubbleStatsView]()

    private var count = 0
    private var bubbleRadiuses: [Double] = [Double]()
    private var minX: CGFloat = 0
    private var minY: CGFloat = 0
    private var maxX: CGFloat = 0
    private var maxY: CGFloat = 0
    private var viewFrames = [CGRect]()
    private var isSized = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        print("commonInit")
        addSubview(contentView)
        decelerationRate = .normal
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        print("layoutSubviews \(frame)")
        if !isSized {
            xOffset = frame.width/2 > -minX ? frame.width/2 : -minX
            yOffset = frame.height/2 > -minY ? frame.height/2 : -minY
            let contentSize = CGSize(width: maxX+xOffset+10, height: maxY+yOffset)
            for i in 0..<count {
                bubbleViews[i].frame.origin.x = viewFrames[i].origin.x + xOffset+10
                bubbleViews[i].frame.origin.y = viewFrames[i].origin.y + yOffset
            }
            
            
            contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
            self.contentSize = contentSize
            isSized = true
        }
        
//        contentOffset = CGPoint(x: -(frame.width-contentSize.width)/2, y: -(frame.height-contentSize.height)/2)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

//MARK: - set up private methods
private extension BubblesStatsScrollView {
    func addBubbleViews() {
        print("addBubbleViews")
        count = bubblesDelegate!.numberOfBubbleViews()
//        let centralView = UIView()
        let centralViewRadius = Double(bubblesDelegate!.radiusOfBubbleView(atIndex: 0))
//        centralView.frame = CGRect(x: 0, y: 0, width: centralViewRadius*2, height: centralViewRadius*2)
////        print(centralView.frame)
//        centralView.backgroundColor = UIColor(red: 0.12, green: 0.57, blue: 0.45, alpha: 1)
//        centralView.layer.cornerRadius = centralViewRadius
//        contentView.addSubview(centralView)
        
        var viewAlphas = [Double]()
        var sumOfAlphas: Double = 0
        var radiuses = [Double]()
        for i in 1..<count {
            let viewRadius = Double(bubblesDelegate!.radiusOfBubbleView(atIndex: i))
            //максимальный требуемый угол для размещения соседнего баббла обозначим maxAlpha
            //чтобы его посчитать воспользуемся формулой 2 * asin( (viewRadius + bubbleMargin) / (centralViewRadius + viewRadius + 2*bubbleMargin) )
//            print("viewRadius \(viewRadius)")
            radiuses.append(centralViewRadius + viewRadius + 2*bubbleMargin)
//            print("beetween centers \(radiuses[i-1])")
            let maxAlpha = 2 * asin( (viewRadius + bubbleMargin) / (radiuses[i-1] ) )
//            print("alpha_i \(maxAlpha)")
            viewAlphas.append(maxAlpha)
            sumOfAlphas += maxAlpha
        }
        //теперь нужно пропорционально увеличить или уменьшить альфы чтобы их сумма была = 360 * 180 / Double.pi
        //коэффициент умножения назовем lambda
//        print(360 * Double.pi / 180)
        let lambda = 360 * Double.pi / (180  * sumOfAlphas ) // для равномерного распределения
//        let lambda = ((360 * Double.pi) / 180 - viewAlphas[0] - viewAlphas[1] - viewAlphas[4]) / (viewAlphas[2] + viewAlphas[3])
//        for a in viewAlphas {
//            print(lambda * a)
//        }
//        print(sumOfAlphas * lambda)
        
        var centeredPositions = [CGPoint]()
        centeredPositions.append(CGPoint(x: 0, y: 0))
        var angleOffset: Double = 0
        
        viewFrames.append(CGRect(x: -centralViewRadius,
                                 y: -centralViewRadius,
                                 width: centralViewRadius*2,
                                 height: centralViewRadius*2))
        
        
//        print(centralViewRadius)
        for i in 1..<count {
            let viewRadius = Double(bubblesDelegate!.radiusOfBubbleView(atIndex: i))
//            viewAlphas[i-1] *= i==2||i==3 ? lambda : 1
            viewAlphas[i-1] *= lambda
            
            let newR = (viewRadius + bubbleMargin) / sin(viewAlphas[i-1] / 2)
//            print(radiuses[i-1])
//            print(newR)
            radiuses[i-1] = newR < radiuses[i-1] ? radiuses[i-1] : newR
//            print(radiuses[i-1])
            angleOffset += i==1 ? 0 : viewAlphas[i-1] / 2
//            print("angleOffset \(angleOffset * 180 / Double.pi)")
            let positionAngle: Double = i==1 ? 0 : viewAlphas[i-1] / 2 + angleOffset
//            print("positionAngle \(positionAngle * 180 / Double.pi)")
            let cx = cos(positionAngle) * radiuses[i-1]
//            print("cx \(cx)")
            let cy = sin(positionAngle) * radiuses[i-1]
//            print("cy \(cy)")
            angleOffset += i==1 ? 0 : viewAlphas[i-1] / 2
            
//            print(viewRadius)
            let viewFrame = CGRect(x: cx-viewRadius,
                                   y: -cy-viewRadius,
                                   width: viewRadius*2,
                                   height: viewRadius*2)
//            print(viewFrame)
            viewFrames.append(viewFrame)
            if i==1 {
                minX = viewFrames[1].origin.x
                minY = viewFrames[1].origin.y
                maxX = viewFrames[1].origin.x + viewFrames[1].width
                maxY = viewFrames[1].origin.y + viewFrames[1].height
            } else {
                minX = minX < viewFrames[i].origin.x ? minX : viewFrames[i].origin.x
                minY = minY < viewFrames[i].origin.y ? minY : viewFrames[i].origin.y
                maxX = maxX > viewFrames[i].origin.x + viewFrames[i].width ?
                    maxX : viewFrames[i].origin.x + viewFrames[i].width
                maxY = maxY > viewFrames[i].origin.y + viewFrames[i].height ?
                    maxY : viewFrames[i].origin.y + viewFrames[i].height
            }
        }
//        print(viewFrames)
//        print(minX)
//        print(minY)
//        print(maxX)
//        print(maxY)
//        print("frame \(frame)")
//        let xOffset = frame.width/2 > -minX ? frame.width/2 : -minX
//        let yOffset = frame.height/2 > -minY ? frame.height/2 : -minY
//        let contentSize = CGSize(width: maxX+xOffset, height: maxY+yOffset)
//        print(contentSize)
        for i in 0..<count {
//            viewFrames[i].origin.x += xOffset
//            viewFrames[i].origin.y += yOffset //+ viewFrames[i].height
            let view = BubbleStatsView()
            view.backgroundColor = UIColor(red: 0.12, green: 0.57, blue: 0.45, alpha: 1)
            view.layer.cornerRadius = bubblesDelegate!.radiusOfBubbleView(atIndex: i)
            view.frame = viewFrames[i]
            contentView.addSubview(view)
            bubbleViews.append(view)
            bubblesDelegate?.setup(bubbleView: view, atIndex: i)
        }
//        print(viewFrames)
//
//
//        contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
//        self.contentSize = contentSize
    }
    
}
