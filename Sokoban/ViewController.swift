//
//  ViewController.swift
//  Sokoban
//
//  Created by Valentin Ozerov on 01.06.17.
//  Copyright © 2017 Valentin Ozerov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var levelImageView: UIImageView!
    @IBOutlet var mainScrollView: UIScrollView!
    
    let cellSize = 100
    let testButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel

        mainScrollView.delegate = self
        mainScrollView.contentSize = CGSize(width: level.width * cellSize, height: level.height * cellSize)
        levelImageView.frame = CGRect(x: 0, y: 0, width: level.width * cellSize, height: level.height * cellSize)

        mainScrollView.minimumZoomScale = 1
        mainScrollView.maximumZoomScale = 2.0
        levelImageView.image = createLevelImage(level: level)

//        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        testButton.backgroundColor = .green
        testButton.setTitle("Test Button", for: .normal)
        
        levelImageView.addSubview(testButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        initDinamicContentLayers()
        setDinamicContentLayers()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return levelImageView
    }
    
    func createLevelImage(level: SPLevel) -> UIImage {
        let levelSize = CGSize(width: cellSize * level.width, height: cellSize * level.height)
        UIGraphicsBeginImageContextWithOptions(levelSize, false, 0.0)
        
        var image: UIImage
        for (i, row) in level.table.enumerated() {
            for (j, cell) in row.enumerated() {
                if cell.type == .empty || cell.type == .wall || cell.type == .goal || cell.type == .boxOnAGoal || cell.type == .playerOnAGoal {
                    image = UIImage(named: cell.imageName)!
                    image.draw(in: CGRect.init(x: j * cellSize, y: i * cellSize, width: cellSize, height: cellSize))
                }
            }
        }

        for (i, row) in level.table.enumerated() {
            for (j, _) in row.enumerated() {
                // Рисуем сплошную стену в случае, если окружают блоки типа .wall
                if i < level.table.count - 1 && j < level.table[i].count - 1 && level.table[i][j].type == .wall && level.table[i + 1][j].type == .wall && level.table[i][j + 1].type == .wall && level.table[i + 1][j + 1].type == .wall {
                    image = UIImage(named: "wall")!
                    image.draw(in: CGRect.init(x: j * cellSize + cellSize / 2, y: i * cellSize + cellSize / 2, width: cellSize, height: cellSize))
                }
            }
        }

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func initDinamicContentLayers() {
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel

        var image: UIImage
        for (_, row) in level.table.enumerated() {
            for (_, cell) in row.enumerated() {
                cell.dinamicContentLayer?.removeFromSuperlayer()
                cell.dinamicContentLayer = nil
                if cell.type == .box || cell.type == .boxOnAGoal || cell.type == .player || cell.type == .playerOnAGoal {
                    cell.dinamicContentLayer = CALayer()
                    var imageName = cell.imageName
                    if cell.type == .boxOnAGoal {
                        imageName = "boxOnAGoal"
                    } else if cell.type == .playerOnAGoal {
                        imageName = "player"
                    }
                    image = UIImage(named: imageName)!
                    cell.dinamicContentLayer?.contents = image.cgImage
                    cell.dinamicContentLayer?.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
                    levelImageView.layer.addSublayer(cell.dinamicContentLayer!)
                }
            }
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        mainScrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, 0, 0)
        setDinamicContentLayers()
    }

    func setDinamicContentLayers() {
        let storage = SPStorage.shared
        let level = storage.currentLevelCollection.currentLevel

//        let offsetX = max((mainScrollView.bounds.width - mainScrollView.contentSize.width) * 0.5, 0)
//        let offsetY = max((mainScrollView.bounds.height - mainScrollView.contentSize.height) * 0.5, 0)

        let fitImageSize = CGSizeAspectFit(aspectRatio: (levelImageView.image?.size)!, boundingSize: levelImageView.frame.size)

//        print("fitImageSize = \(fitImageSize)")

        let zoom = UIScreen.main.bounds.width / (levelImageView.image?.size.width)!

        let offsetX = (levelImageView.frame.width - fitImageSize.width) / 2
        let offsetY = (levelImageView.frame.height - fitImageSize.height) / 2
        
        let cellSizeWithZoom = CGFloat(cellSize) * zoom
        for (i, row) in level.table.enumerated() {
            for (j, cell) in row.enumerated() {
                cell.dinamicContentLayer?.frame = CGRect(x: CGFloat(j) * cellSizeWithZoom + offsetX, y: CGFloat(i) * cellSizeWithZoom + offsetY, width: cellSizeWithZoom, height: cellSizeWithZoom)
                cell.dinamicContentLayer?.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
            }
        }
    }
    
    func rotated() {
        setDinamicContentLayers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
   //     setDinamicContentLayers()
    }
    
    private func CGSizeAspectFit(aspectRatio:CGSize, boundingSize:CGSize) -> CGSize
    {
        var aspectFitSize = boundingSize
        let mW = boundingSize.width / aspectRatio.width
        let mH = boundingSize.height / aspectRatio.height
        if( mH < mW )
        {
            aspectFitSize.width = mH * aspectRatio.width
        }
        else if( mW < mH )
        {
            aspectFitSize.height = mW * aspectRatio.height
        }
        return aspectFitSize
    }
}

