// main
//  ImageOpenView.swift
//  Gallery
//
//  Created by Hitesh Bansal on 31/08/22.
//

import UIKit


class ImageOpenView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    var myCollectionView : UICollectionView!
    var imageArray = [UIImage] ()
    var passedContentOffset = IndexPath()
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier : "Cell", for : indexPath) as! ImageOpenViewCell
        print(indexPath.self)
        cell.imgView.image = imageArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let img = imageArray[indexPath.self[1]]
        var width = img.size.width
        var height = img.size.height
        //print("Width: \(width), Height: \(height)")
        let scaleWidth = myCollectionView.frame.width/width
        let scaleHeight = myCollectionView.frame.width/height
        let scale = min(scaleWidth, scaleHeight)
        
        width = max(scale * width, myCollectionView.frame.width)
        height = max(scale * height, myCollectionView.frame.width)
        let newSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        img.draw(in: CGRect(origin: .zero, size: newSize))
        imageArray[indexPath.self[1]] = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        //print("Width: \(width), Height: \(height)")
        return CGSize(width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Here")
        
        view.backgroundColor = UIColor.white
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.register(ImageOpenViewCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.isPagingEnabled = true
        myCollectionView.scrollToItem(at: passedContentOffset, at: .left, animated: true)
        
        self.view.addSubview(myCollectionView)
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue) ))
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.itemSize = myCollectionView.frame.size
        flowLayout.invalidateLayout()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = myCollectionView.contentOffset
        let width  = myCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        myCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.myCollectionView.reloadData()
            self.myCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    
    class ImageOpenViewCell: UICollectionViewCell, UIScrollViewDelegate {
        var imgView: UIImageView!
        var scrollImg: UIScrollView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            scrollImg = UIScrollView()
            scrollImg.delegate = self
            scrollImg.showsVerticalScrollIndicator = true
            scrollImg.flashScrollIndicators()
            scrollImg.minimumZoomScale = 1.0
            scrollImg.maximumZoomScale = 4.0
            
            let doubleTapAction = UITapGestureRecognizer(target: self, action: #selector(doubleTapActionScrollView(recognizer:)))
            doubleTapAction.numberOfTapsRequired = 2
            scrollImg.addGestureRecognizer(doubleTapAction)
            self.addSubview(scrollImg)
            
            imgView = UIImageView()
            imgView.image = UIImage(named: "user3")
            scrollImg.addSubview(imgView!)
            imgView.contentMode = .scaleAspectFill
        }
        
        
        
        override func layoutSubviews() {
            super.layoutSubviews()
            scrollImg.frame = self.bounds
            imgView.frame = self.bounds
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            scrollImg.setZoomScale(1, animated: true)
        }
        
        @objc func doubleTapActionScrollView(recognizer: UITapGestureRecognizer) {
            if scrollImg.zoomScale == scrollImg.minimumZoomScale {
                scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
            }
            else {
                scrollImg.setZoomScale(scrollImg.minimumZoomScale, animated: true)
            }
        }
        
        func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
            var zoomRect = CGRect.zero
            zoomRect.size.width = imgView.frame.size.width / scale
            zoomRect.size.height = imgView.frame.size.height / scale
            let zoomRectCenter = imgView.convert(center, from: scrollImg)
            zoomRect.origin.x = zoomRectCenter.x - (zoomRect.size.width/2.0)
            zoomRect.origin.y = zoomRectCenter.y - (zoomRect.size.height/2.0)
            return zoomRect
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return self.imgView
        }
        
        
        
        required init?(coder aDecoder: NSCoder){
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}

