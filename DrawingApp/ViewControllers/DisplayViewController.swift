//
//  DisplayViewController.swift
//  DrawingApp
//
//  Created by Nuthan Raju Pesala on 23/06/20.
//  Copyright © 2020 Nuthan Raju Pesala. All rights reserved.
//

import UIKit
import FirebaseStorage

class DisplayViewController: UIViewController {
    
      lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        layout.scrollDirection = .vertical
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    let label: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Drawings,Go to Drawing pad draw something and come back"
        label.textColor = UIColor.blue
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    var arrayOfImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Drawings"
        
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleBack))
        leftBarButton.tintColor = .black
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
        
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.backgroundColor = UIColor.clear
        
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        
        self.getAllImagesfromLocalStorage()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if arrayOfImages.count != 0 {
            label.isHidden = true
        }else {
              label.isHidden = false
        }
    }
    @objc func handleBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getAllImagesfromLocalStorage() {
        let fileManager = FileManager.default
        do {
            let docDirectoryUrl = try! fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderName = docDirectoryUrl.appendingPathComponent("Drawings")
            guard let filePaths = try? fileManager.contentsOfDirectory(at: folderName, includingPropertiesForKeys: nil, options: []) else {  print("Error get Image")
                return }
            for filePath in filePaths {
                do {
                    let imageData = try Data(contentsOf: filePath.absoluteURL)
                    arrayOfImages.append(UIImage(data: imageData)!)
                }catch {
                    print("Failed to get Images")
                }
                
            }
        }
    }
}

extension DisplayViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayOfImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        cell.drawingImage.image = arrayOfImages[indexPath.item]
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            let imageView = self.arrayOfImages[indexPath.item]
            let newImageView = UIImageView(image: imageView)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissImage(sender: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.5) {
            sender.view?.removeFromSuperview()
            self.navigationController?.isNavigationBarHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
}

extension DisplayViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/2 - 4, height: collectionView.bounds.height/2 - 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    let drawingImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(drawingImage)
        drawingImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        drawingImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        drawingImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        drawingImage.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
