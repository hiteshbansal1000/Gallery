// main
//  ViewController.swift
//  Gallery
//
//  Created by Hitesh Bansal on 26/08/22.
//
// Read about MVM
import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    
    var urlString : String = "https://api.imgflip.com/get_memes"
    var imageDataObj : [ imageData] = []
    
    
    
    var myCollectionView : UICollectionView! // To see alternative
    var imageArray = [UIImage] ()
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier : "Cell", for : indexPath) as! PhotoItemCell
        cell.img.image = imageArray[indexPath.item]
        return cell
    }
    
    struct ResponseData : Codable {
        var data : InnerResponseData
        var success : Bool
    }
    
    struct InnerResponseData : Codable {
        var memes : [ imageData ]
    }
    
    struct imageData : Codable {
        var id : String
        var name : String
        var width : Int
        var height: Int
        var url: String
        var box_count: Int // To see JSON _ to Camel case
    } // To do if json image data missing then do the required
    
    
    func Display() { // syntax
        let screenHeight, screenWidth : CGFloat
        let screen = UIScreen.main.bounds
        screenHeight = screen.size.height
        screenWidth = screen.size.width
        print("screenHeight : \(screenHeight) screenWidth : \(screenWidth)")
        
        
        return
    }
    
    private func loadJson(fromURLString urlString : String, completion: @escaping (Result<Data, Error>) -> Void){
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
    private func parse(jsonData : Data){
        do{
            //print(String(data: jsonData, encoding: String.Encoding.utf8))
            let decodedData = try JSONDecoder().decode(ResponseData.self, from: jsonData)
            let imgData = decodedData.data.memes
            self.imageDataObj = imgData
            print(imgData.count)
            for i in 0...(imgData.count - 1) {
                print("ID: \(imgData[i].id)")
                print("Name: \(imgData[i].name)")
                print("Width: \(imgData[i].width)")
                print("Height: \(imgData[i].height)")
                print("URL: \(imgData[i].url)")
            }
            self.loadImage()
            DispatchQueue.global().async {
                print("Main Queue")
                DispatchQueue.main.async {
                    print("Running on the Main Queue")
                    self.myCollectionView.reloadData()
                }
            }
        }
        catch{
            print("Error in Decoding")
        }
    }

    override func viewDidLoad() { // View COntrolller Life cycle read
        super.viewDidLoad()
        self.title = "Gallery"
        view.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor = UIColor.white
        self.view.addSubview(myCollectionView)
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue) )) // Use autolayout instead of this
        
        Display()
        self.loadJson(fromURLString: urlString){ (result) in // Closure Fix me Memory Leak Destructor
            switch result {
            case .success(let data):
                self.parse(jsonData : data)
            case .failure(let error):
                print(error)
            }
        }
        
        
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ImageVC = ImageOpenView()
        print("This",indexPath)
        ImageVC.imageArray = self.imageArray
        ImageVC.passedContentOffset = indexPath
        self.navigationController?.pushViewController(ImageVC, animated: true)
    }
    
    private func loadImage() { // Fix Me
        let imgcount = imageDataObj.count
        for i in 0...(imgcount - 1) {
            let url = URL(string: imageDataObj[i].url)!
            DispatchQueue.global().sync {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.sync { // Dont call sync
                        let img_temp = UIImage(data: data) //  Reusability Read
                        print(img_temp!)
                        print("Loaded \(i)")
                        self.imageArray.append(img_temp!)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 5
        //print("Width: \(width), Height: \(height)")
        let sizeImagePortrait = width/4, sizeImageLandscape = width/6
        let isPortrait = UIDevice.current.orientation.isValidInterfaceOrientation ? UIDevice.current.orientation.isPortrait: (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait)! // See
        if isPortrait {
            return CGSize(width: sizeImagePortrait-1, height: sizeImagePortrait-1)
        }
        else {
            return CGSize(width: sizeImageLandscape-1, height: sizeImageLandscape-1)
        }
    }
    
    class PhotoItemCell : UICollectionViewCell {
        var img = UIImageView()
        
        
        override init(frame: CGRect){
            super.init(frame: frame) //autolayouts to use instaed of frame
            img.contentMode = .scaleAspectFill
            img.clipsToBounds = true
            self.addSubview(img)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            img.frame = self.bounds
        }
        
        required init?(coder: NSCoder) {
            fatalError("init?(coder:) is not implemented")
        }
    }


}


