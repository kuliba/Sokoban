//
//  FeedViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 09/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit
import iCarousel
import DeviceKit

class FeedViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet var carousel: iCarousel!
    @IBOutlet weak var containerView: UIView!
    
    lazy var leftSwipeRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        recognizer.direction = .left
        return recognizer
    }()
    lazy var rightSwipeRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        recognizer.direction = .right
        return recognizer
    }()
    var previousIndex = -1
    
    var labels = [UILabel?]()
    var gradientViews = [GradientView2]()
    
    let iphone5Devices = Constants.iphone5Devices
    let xDevices = Constants.xDevices
    
    weak var currentViewController: UIViewController?
    
    var items = ["Текущее", "Предстоящее", "Предложения", "Информация", "Настройки"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        currentViewController = storyboard?.instantiateViewController(withIdentifier: "feed2")
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(currentViewController!)
        addSubview(self.currentViewController!.view, toView: self.containerView)
        
        labels = [UILabel?].init(repeating: nil, count: items.count)
        super.viewDidLoad()
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .wheel
        carousel.bounces = false
        // carousel.isPagingEnabled = true
        // carousel.isScrollEnabled = false
        //carousel.currentItemIndex = 2
        carousel.scrollToItem(at: 2, animated: false)
        addGradients()
        gradientViews[0].alpha = 1
        
        containerView.addGestureRecognizer(leftSwipeRecognizer)
        containerView.addGestureRecognizer(rightSwipeRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if Device().isOneOf(xDevices) {
            carousel.frame.size.height = 120
        } else {
            carousel.frame.size.height = 90
        }
    }
}

// MARK: - iCarousel Delegate and DataSource
extension FeedViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
            itemView.backgroundColor = .clear
            
            label = UILabel(frame: itemView.bounds)
            
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
            label.font = UIFont(name: "Roboto-Light", size: 16)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        // set item label
        // remember to always set any properties of your carousel item
        // views outside of the `if (view == nil) {...}` check otherwise
        // you'll get weird issues with carousel item content appearing
        // in the wrong place in the carousel
        label.text = "\(items[index])"
        labels[index] = label
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == .wrap {
            return 0.0
        }
        
        if option == .arc {
            if Device().isOneOf(iphone5Devices) {
                return CGFloat(Double.pi) / 1.75 // 2.75 - if not authorized
            } else if Device().isOneOf(xDevices) {
                return CGFloat(Double.pi) / 2.5 // 3.5 - if not authorized
            } else {
                return CGFloat(Double.pi) / 2.5 // 3.5 - if not authorized
            }
        }
        
        if option == .radius {
            if Device().isOneOf(iphone5Devices) {
                return 800
            } else if Device().isOneOf(xDevices) {
                return 1300
            } else {
                return 1300
            }
        }
        
        return value
    }
    
    func numberOfPlaceholders(in carousel: iCarousel) -> Int {
        return 6
    }
    
    func carousel(_ carousel: iCarousel, placeholderViewAt index: Int, reusing view: UIView?) -> UIView {
        return UIView()
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        labels[previousIndex]?.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        labels[previousIndex]?.font = UIFont(name: "Roboto-Light", size: 16)

        labels[index]?.textColor = .white
        labels[index]?.font = UIFont(name: "Roboto-Regular", size: 16)
        previousIndex = index
        showComponent(index: index)
        for (i, n) in gradientViews.enumerated() {
            UIView.animate(withDuration: 0.25, animations: {
                n.alpha = index == i ? 1 : 0
            })
        }
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        if previousIndex<0 || previousIndex == carousel.currentItemIndex{
            previousIndex = carousel.currentItemIndex
            labels[carousel.currentItemIndex]?.textColor = .white
            labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)
            return
        }
        labels[previousIndex]?.textColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        labels[previousIndex]?.font = UIFont(name: "Roboto-Light", size: 16)
        labels[carousel.currentItemIndex]?.textColor = .white
        labels[carousel.currentItemIndex]?.font = UIFont(name: "Roboto-Regular", size: 16)
        previousIndex = carousel.currentItemIndex
        showComponent(index: carousel.currentItemIndex)
        for (i, n) in gradientViews.enumerated() {
            UIView.animate(withDuration: 0.25, animations: {
                n.alpha = carousel.currentItemIndex == i ? 1 : 0
            })
        }
    }
}

// MARK: - Private methods
private extension FeedViewController {
    func addSubview(_ subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                           options: [], metrics: nil, views: viewBindingsDict
        ))
        
        parentView.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                           options: [], metrics: nil, views: viewBindingsDict
        ))
    }
    
    func addGradients() {
        let gradients = [
            (UIColor(hexFromString: "EA4644"), UIColor(hexFromString: "F1AD72")),
            (UIColor(hexFromString: "F1AD72"), UIColor(hexFromString: "EA4544")),
            (UIColor(hexFromString: "EA4544"), UIColor(hexFromString: "F1AD72")),
            (UIColor(hexFromString: "F1AD72"), UIColor(hexFromString: "EA4544")),
            (UIColor(hexFromString: "EA4544"), UIColor(hexFromString: "F1AD72"))
        ]
        
        for gradient in gradients {
            let v = GradientView2()
            v.color1 = gradient.0
            v.color2 = gradient.1
            v.alpha = 0
            v.frame = view.frame
            v.addGradientView()
            v.layoutIfNeeded()
            gradientViews.append(v)
            view.insertSubview(v, at: 0)
        }
    }
    
    func showComponent(index: Int) {
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "feed\(index)")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        currentViewController = newViewController
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        addChild(newViewController)
        addSubview(newViewController.view, toView:self.containerView!)
        // TODO: Set the starting state of your constraints here
        newViewController.view.alpha = 0
        newViewController.view.bounds.origin.y -= 10
        
        newViewController.view.layoutIfNeeded()
        
        // TODO: Set the ending state of your constraints here
        
        UIView.animate(withDuration: 0.25, animations: {
            oldViewController.view.alpha = 0
            oldViewController.view.bounds.origin.y -= 10
            // only need to call layoutIfNeeded here
            newViewController.view.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                newViewController.view.alpha = 1
                newViewController.view.bounds.origin.y += 10
            }, completion: { _ in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParent()
                newViewController.didMove(toParent: self)
            })
        })
    }
    
    @objc func swipeAction(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if carousel.currentItemIndex < carousel.numberOfItems-1 {
                carousel.scrollToItem(at: carousel.currentItemIndex+1, animated: true)
            }
        } else if gesture.direction == .right {
            if carousel.currentItemIndex > 0 {
                carousel.scrollToItem(at: carousel.currentItemIndex-1, animated: true)
            }
        }
    }
}

@IBDesignable
class CircularLabel: UILabel {
    // *******************************************************
    // DEFINITIONS (Because I'm not brilliant and I'll forget most this tomorrow.)
    // Radius: A straight line from the center to the circumference of a circle.
    // Circumference: The distance around the edge (outer line) the circle.
    // Arc: A part of the circumference of a circle. Like a length or section of the circumference.
    // Theta: A label or name that represents an angle.
    // Subtend: A letter has a width. If you put the letter on the circumference, the letter's width
    //          gives you an arc. So now that you have an arc (a length on the circumference) you can
    //          use that to get an angle. You get an angle when you draw a line from the center of the
    //          circle to each end point of your arc. So "subtend" means to get an angle from an arc.
    // Chord: A line segment connecting two points on a curve. If you have an arc then there is a
    //          start point and an end point. If you draw a straight line from start point to end point
    //          then you have a "chord".
    // sin: (Super simple/incomplete definition) Or "sine" takes an angle in degrees and gives you a number.
    // asin: Or "asine" takes a number and gives you an angle in degrees. Opposite of sine.
    //          More complete definition: http://www.mathsisfun.com/sine-cosine-tangent.html
    // cosine: Also takes an angle in degrees and gives you another number from using the two radiuses (radii).
    // *******************************************************
    
    @IBInspectable var angle: CGFloat = 1.6
    @IBInspectable var clockwise: Bool = true
    
    override func draw(_ rect: CGRect) {
        centreArcPerpendicular()
    }
    /**
     This draws the self.text around an arc of radius r,
     with the text centred at polar angle theta
     */
    func centreArcPerpendicular() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let string = text ?? ""
        let size   = bounds.size
        context.translateBy(x: size.width / 2, y: size.height / 2)
        
        let radius = getRadiusForLabel()
        let l = string.count
        let attributes = [NSAttributedString.Key.font : self.font!]
        
        let characters: [String] = string.map { String($0) } // An array of single character strings, each character in str
        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string
        
        // Calculate the arc subtended by each letter and their total
        for i in 0 ..< l {
            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: radius)]
            totalArc += arcs[i]
        }
        
        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
        // or anti-clockwise (right way up at 6 o'clock)?
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection = clockwise ? -CGFloat.pi/2 : CGFloat.pi/2
        
        // The centre of the first character will then be at
        // thetaI = theta - totalArc / 2 + arcs[0] / 2
        // But we add the last term inside the loop
        var thetaI = angle - direction * totalArc / 2
        
        for i in 0 ..< l {
            thetaI += direction * arcs[i] / 2
            // Call centre with each character in turn.
            // Remember to add +/-90º to the slantAngle otherwise
            // the characters will "stack" round the arc rather than "text flow"
            centre(text: characters[i], context: context, radius: radius, angle: thetaI, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * arcs[i] / 2
        }
    }
    
    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        // *******************************************************
        // Simple geometry
        // *******************************************************
        return 2 * asin(chord / (2 * radius))
    }
    
    /**
     This draws the String str centred at the position
     specified by the polar coordinates (r, theta)
     i.e. the x= r * cos(theta) y= r * sin(theta)
     and rotated by the angle slantAngle
     */
    func centre(text str: String, context: CGContext, radius r:CGFloat, angle theta: CGFloat, slantAngle: CGFloat) {
        // Set the text attributes
        let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: textColor!,
            NSAttributedString.Key.font: font!
        ]
        // Save the context
        context.saveGState()
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        // Calculate the width of the text
        let offset = str.size(withAttributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy(x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        // Draw the text
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        // Restore the context
        context.restoreGState()
    }
    
    func getRadiusForLabel() -> CGFloat {
        // Imagine the bounds of this label will have a circle inside it.
        // The circle will be as big as the smallest width or height of this label.
        // But we need to fit the size of the font on the circle so make the circle a little
        // smaller so the text does not get drawn outside the bounds of the circle.
        let smallestWidthOrHeight = min(bounds.size.height, bounds.size.width)
        let heightOfFont = text?.size(withAttributes: [NSAttributedString.Key.font: self.font]).height ?? 0
        
        // Dividing the smallestWidthOrHeight by 2 gives us the radius for the circle.
        return (smallestWidthOrHeight/2) - heightOfFont + 5
    }
}
