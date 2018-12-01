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
            print("bubblesDelegate didSet \(String(describing: bubblesDelegate))")
            count = bubblesDelegate!.numberOfBubbleViews()
            resizeScales = Array.init(repeating: 1, count: count)
            addBubbleViews()
            calculateFrames()
            
            for i in 0..<count {
                bubbleViews[i].frame = viewFrames[i]
                bubbleViews[i].layer.cornerRadius = bubblesDelegate!.radiusOfBubbleView(atIndex: i) //* resizeScales[i]
            }
            
            xOffset = -minX //frame.width/2 > -minX ? frame.width/2 : -minX
            yOffset = -minY //frame.height/2 > -minY ? frame.height/2 : -minY
            let contentSize = CGSize(width: maxX+xOffset+10, height: maxY+yOffset)
            for i in 0..<count {
                bubbleViews[i].frame.origin.x = viewFrames[i].origin.x + xOffset+10
                bubbleViews[i].frame.origin.y = viewFrames[i].origin.y + yOffset
            }
//            centralBubbleCenter = bubbleViews[0].center
            
            contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
            self.contentSize = contentSize
 
            isSized = true
        }
    }
    var bubbleMargin: Double = 3
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    var bubbleViews: [BubbleStatsView] = [BubbleStatsView]()
    var baseOffset: CGPoint = CGPoint.zero

    private var count = 0
//    private var bubbleRadiuses: [Double] = [Double]()
    private var minX: CGFloat = 0
    private var minY: CGFloat = 0
    private var maxX: CGFloat = 0
    private var maxY: CGFloat = 0
    private var viewFrames = [CGRect]()
    private var isSized = false
//    private var centralBubbleCenter: CGPoint = CGPoint.zero
    private var distances = [Double]()
    private var resizeScales = [CGFloat]()
    
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
    }
    
    func updateBubbles() {
//        resizeScales = Array.init(repeating: 1, count: count)
        calculateFrames()
        
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            
            for i in 0..<self.count {
                
                self.bubblesDelegate?.setup(bubbleView: self.bubbleViews[i], atIndex: i)
                self.bubbleViews[i].frame = self.viewFrames[i]
//                print("i \(i)")
//                print("scale \(self.resizeScales[i])")
//                print("last corner \(self.bubbleViews[i].layer.cornerRadius)")
//                print("last rad \(self.bubbleViews[i].frame.width/2)")
//                print("last rad/scale \(self.bubbleViews[i].frame.width/(2*self.resizeScales[i]))")
//                self.bubbleViews[i].layer.cornerRadius = self.bubblesDelegate!.radiusOfBubbleView(atIndex: i) //* self.resizeScales[i]
//                print("new corner \(self.bubbleViews[i].layer.cornerRadius)")
//                print("new rad \(self.bubblesDelegate!.radiusOfBubbleView(atIndex: i))")
//                print("new rad/scale \(self.bubblesDelegate!.radiusOfBubbleView(atIndex: i) / self.resizeScales[i])")
            }
//
            self.xOffset = -self.minX //frame.width/2 > -minX ? frame.width/2 : -minX
            self.yOffset = -self.minY //frame.height/2 > -minY ? frame.height/2 : -minY
            let contentSize = CGSize(width: self.maxX+self.xOffset+10, height: self.maxY+self.yOffset)
            for i in 0..<self.count {
                self.bubbleViews[i].frame.origin.x = self.viewFrames[i].origin.x + self.xOffset+10
                self.bubbleViews[i].frame.origin.y = self.viewFrames[i].origin.y + self.yOffset
//                self.bubbleViews[i].layoutIfNeeded()
            }
//
            self.contentView.frame = CGRect(origin: CGPoint.zero, size: contentSize)
            self.contentSize = contentSize
            print(self.contentInset.top)
            print(contentSize.height)
            print(self.bounds.height)
            print( (-self.contentSize.height + self.bounds.height - 60)/2 )

            self.contentInset = UIEdgeInsets(top: (-self.contentSize.height + self.bounds.height - 60)/2, left: 0, bottom: 0, right: 0)
            self.layoutIfNeeded()

        }, completion: {(_) in
            self.isUserInteractionEnabled = true
        })
        for i in 0..<self.count {
            let animation = CABasicAnimation(keyPath:"cornerRadius")
//            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            animation.fromValue = self.bubbleViews[i].layer.cornerRadius
            animation.toValue = self.bubblesDelegate!.radiusOfBubbleView(atIndex: i)
            animation.duration = 0.3
            bubbleViews[i].layer.add(animation, forKey: "cornerRadius")
            bubbleViews[i].layer.cornerRadius = self.bubblesDelegate!.radiusOfBubbleView(atIndex: i)
        }
        
    }
    
    override func layoutSubviews() {
//        print("layoutSubviews \(frame)")
        if isSized {

            let offset = CGPoint(x: -contentOffset.x+baseOffset.x,
                                 y: -contentOffset.y+baseOffset.y )
            let centerOffset = CGPoint(x: -offset.x+bubbleViews[0].center.x,
                                       y: -offset.y+bubbleViews[0].center.y )

            let maxDiff: Float = 50
            for i in 0..<count {
                let dx = centerOffset.x - bubbleViews[i].center.x
                let dy = centerOffset.y - bubbleViews[i].center.y //+ contentInset.top
                let distanceToCenter = sqrtf(Float(dx*dx + dy*dy))
                
                var diff = distanceToCenter - Float(distances[i])
//                print("diff \(diff)")
                diff /= 5
                var scale: CGFloat = 0
                if Float(diff)>maxDiff {
                    scale = 0.5
                } else if Float(diff) < -maxDiff {
                    scale = 1.5
                } else {
                    scale = CGFloat(1 - (Float(diff)/(1.8*maxDiff)))
                }
//                print("scale \(scale)")
                resizeScales[i] = scale
//                bubbleViews[i].transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            calculateFrames()
            
            xOffset = -minX //frame.width/2 > -minX ? frame.width/2 : -minX
            yOffset = -minY //frame.height/2 > -minY ? frame.height/2 : -minY
            for i in 0..<count {

                bubbleViews[i].frame.origin.x = viewFrames[i].origin.x + xOffset+10
                bubbleViews[i].frame.origin.y = viewFrames[i].origin.y + yOffset

                bubbleViews[i].scale = resizeScales[i]
                
            }
        }
        super.layoutSubviews()

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
        for i in 0..<count {
            let view = BubbleStatsView()
            view.backgroundColor = UIColor(red: 0.12, green: 0.57, blue: 0.45, alpha: 1)
//            view.layer.cornerRadius = bubblesDelegate!.radiusOfBubbleView(atIndex: i)
            contentView.addSubview(view)
            bubbleViews.append(view)
            bubblesDelegate?.setup(bubbleView: view, atIndex: i)
        }
    }
    
    func calculateFrames() {
//        print("calculateFrames")
        let centralViewRadius = Double(bubblesDelegate!.radiusOfBubbleView(atIndex: 0) * resizeScales[0])
        
        var viewAlphas = [Double]()
        var sumOfAlphas: Double = 0
        distances = [0]
        for i in 1..<count {
            let viewRadius = Double(bubblesDelegate!.radiusOfBubbleView(atIndex: i) * resizeScales[i])
            //максимальный требуемый угол для размещения соседнего баббла обозначим maxAlpha
            //чтобы его посчитать воспользуемся формулой 2 * asin( (viewRadius + bubbleMargin) / (centralViewRadius + viewRadius + 2*bubbleMargin) )
            //            print("viewRadius \(viewRadius)")
            distances.append(centralViewRadius + viewRadius + 2*bubbleMargin)
            //            print("beetween centers \(radiuses[i-1])")
            let maxAlpha = 2 * asin( (viewRadius + bubbleMargin) / (distances[i] ) )
            //            print("alpha_i \(maxAlpha)")
            viewAlphas.append(maxAlpha)
            sumOfAlphas += maxAlpha
        }
        //теперь нужно пропорционально увеличить или уменьшить альфы чтобы их сумма была = 360 * 180 / Double.pi
        //коэффициент умножения назовем lambda
        //        print(360 * Double.pi / 180)
        let lambda = 360 * Double.pi / (180  * sumOfAlphas ) // для равномерного распределения
        //        let lambda = ((360 * Double.pi) / 180 - viewAlphas[0] - viewAlphas[1] - viewAlphas[4]) / (viewAlphas[2] + viewAlphas[3])

        var centeredPositions = [CGPoint]()
        centeredPositions.append(CGPoint(x: 0, y: 0))
        var angleOffset: Double = 0
        
        viewFrames = [CGRect(x: -centralViewRadius,
                             y: -centralViewRadius,
                             width: centralViewRadius*2,
                             height: centralViewRadius*2)]
        
        
        for i in 1..<count {
            let viewRadius = Double(bubblesDelegate!.radiusOfBubbleView(atIndex: i) * resizeScales[i])
            viewAlphas[i-1] *= lambda
            
            let newR = (viewRadius + bubbleMargin) / sin(viewAlphas[i-1] / 2)
            distances[i] = newR < distances[i] ? distances[i] : newR
            angleOffset += i==1 ? 0 : viewAlphas[i-1] / 2
            let positionAngle: Double = i==1 ? 0 : viewAlphas[i-1] / 2 + angleOffset
            let cx = cos(positionAngle) * distances[i]
            let cy = sin(positionAngle) * distances[i]
            angleOffset += i==1 ? 0 : viewAlphas[i-1] / 2
            
            let viewFrame = CGRect(x: cx-viewRadius,
                                   y: -cy-viewRadius,
                                   width: viewRadius*2,
                                   height: viewRadius*2)
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
        
    }
}

