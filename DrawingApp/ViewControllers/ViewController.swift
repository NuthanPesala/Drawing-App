//
//  ViewController.swift
//  DrawingApp
//
//  Created by Nuthan Raju Pesala on 21/06/20.
//  Copyright © 2020 Nuthan Raju Pesala. All rights reserved.
//

import UIKit
import FirebaseStorage

class ViewController: UIViewController {
    
    let canvasView: CanvasView = {
        let view = CanvasView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        layout.scrollDirection = .horizontal
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    let brushSizeSlider: UISlider = {
       let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = .white
        slider.value = 0.6
        slider.addTarget(self, action: #selector(brushSizeBtnTapped(sender: )), for: .valueChanged)
        return slider
    }()
    
    let opacitySlider: UISlider = {
        let slider = UISlider()
        slider.thumbTintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(opacityBtnTapped(sender: )), for: .valueChanged)
        slider.value = 1
        return slider
    }()
    
    let containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let buttonToExtend: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleExtendView), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        return button
    }()
    
    let undoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(undoBtnTapped), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        button.tintColor = .black
        return button
       }()
    
    let clearButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearBtnTapped), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage(systemName: "clear.fill"), for: .normal)
        button.tintColor = .black
        return button
         }()
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(uploadBtnTapped), for: UIControl.Event.touchUpInside)
        button.setImage(UIImage(systemName: "square.and.arrow.down.fill"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: label.font.familyName, size: 14)
        label.text = "Size"
        return label
    }()
    
    let opacityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: label.font.familyName, size: 14)
        label.text = "Opacity"
        return label
    }()
    
    let recentDrawingBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Recent Drawings", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(recentBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    var colors: [UIColor] = [ .systemPurple, .systemIndigo, .systemBlue, .systemGreen, .systemYellow, .systemOrange, .systemRed, .systemGray, .brown, .cyan, .magenta, .systemTeal, .systemPink, .black, .white, .darkGray, .link]
                    
    var heightConstraint: NSLayoutConstraint?
    
    var recentBtnHeight: NSLayoutConstraint?
    
    var isExtend: Bool = false
    
    var isFromMore: Bool = false
    
    var navBarHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Drawing Pad"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "more")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(moreBtnTapped))
        rightBarButton.tintColor = .black
        navigationItem.setRightBarButton(rightBarButton, animated: true)
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = (window?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0.0) +      (navigationController?.navigationBar.frame.height ?? 0.0)
        
        if statusBarHeight != 0 {
            navBarHeight = statusBarHeight
        }
       
        self.initailSetup()
    }
    
     // MARK: - UISetup Programatically -
    
    func initailSetup() {
        
        // Label
        canvasView.label.isHidden = false
        canvasView.addSubview(canvasView.label)
        canvasView.label.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor, constant: 0).isActive = true
        canvasView.label.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor).isActive = true
        
        // ContainerView
        view.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -14).isActive = true
        heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint?.isActive = true
        containerView.backgroundColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.6)
        
        // ButtonToExtend
        containerView.addSubview(buttonToExtend)
        buttonToExtend.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).isActive = true
        buttonToExtend.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        buttonToExtend.widthAnchor.constraint(equalToConstant: 25).isActive = true
        buttonToExtend.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
    
        //clearButton
        containerView.addSubview(clearButton)
        clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).isActive = true
        clearButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        clearButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        
        // undobutton
        containerView.addSubview(undoButton)
        undoButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -4).isActive = true
        undoButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25).isActive = true
        undoButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        undoButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        
        // uploadButton
        containerView.addSubview(uploadButton)
        uploadButton.trailingAnchor.constraint(equalTo: undoButton.leadingAnchor, constant: -4).isActive = true
        uploadButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 23).isActive = true
        uploadButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        uploadButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        // collectionView
        containerView.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 23).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: uploadButton.leadingAnchor, constant: -2).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        collectionView.backgroundColor = UIColor.clear
        

        // CanvasView
        view.addSubview(canvasView)
        canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        // Recent Drwaings button
        canvasView.addSubview(recentDrawingBtn)
        recentDrawingBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        recentDrawingBtn.topAnchor.constraint(equalTo: canvasView.topAnchor, constant: navBarHeight).isActive = true
        recentDrawingBtn.widthAnchor.constraint(equalToConstant: 120).isActive = true
        recentBtnHeight = recentDrawingBtn.heightAnchor.constraint(equalToConstant: 0)
        recentBtnHeight?.isActive = true
        self.recentDrawingBtn.isHidden = true
        
        //sizeLabel
        containerView.addSubview(sizeLabel)
        sizeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        sizeLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 18).isActive = true
        sizeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //brush Slider
        containerView.addSubview(brushSizeSlider)
        brushSizeSlider.leadingAnchor.constraint(equalTo: sizeLabel.trailingAnchor, constant: 10).isActive = true
        brushSizeSlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        brushSizeSlider.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 15).isActive = true
        
        //opacity label
        containerView.addSubview(opacityLabel)
        opacityLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        opacityLabel.topAnchor.constraint(equalTo: brushSizeSlider.bottomAnchor, constant: 13).isActive = true
        opacityLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        //opacity slider
        containerView.addSubview(opacitySlider)
        opacitySlider.leadingAnchor.constraint(equalTo: opacityLabel.trailingAnchor, constant: 10).isActive = true
        opacitySlider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        opacitySlider.topAnchor.constraint(equalTo: brushSizeSlider.bottomAnchor, constant: 10).isActive = true
        
    }
    
    //MARK:- Actions -
    
    @objc func handleExtendView() {
        if !isExtend {
            self.heightConstraint?.constant = 150
            buttonToExtend.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        }else {
            self.heightConstraint?.constant = 60
            buttonToExtend.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        isExtend = !isExtend
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func brushSizeBtnTapped(sender: UISlider) {
        canvasView.strokeWidth = CGFloat(sender.value) * 10
    }
    
    @objc func opacityBtnTapped(sender: UISlider) {
        canvasView.strokeOpacity = CGFloat(sender.value) 
    }
    
    @objc func undoBtnTapped() {
        canvasView.undoLines()
    }
    
    @objc func clearBtnTapped() {
        canvasView.clearCanvasView()
    }
    
    @objc func uploadBtnTapped() {
        let image = canvasView.takeScreenshot()
        if image != nil {
        self.uploadImageToFirebaseStorage(image: image)
        }else {
        canvasView.label.isHidden = false
        }
    }
    
 
    
    @objc func moreBtnTapped() {
        
        UIView.animate(withDuration: 0.7) {
            if self.isFromMore == false {
                self.recentDrawingBtn.isHidden = false
                self.recentBtnHeight?.constant = 30
            }else {
                self.recentDrawingBtn.isHidden = true
                self.recentBtnHeight?.constant = 0
            }
            self.view.layoutIfNeeded()
        }
        
        self.isFromMore = !self.isFromMore
    }
    
    @objc func recentBtnTapped() {
        let displayVC = self.storyboard?.instantiateViewController(identifier: "DisplayViewController") as! DisplayViewController
        self.navigationController?.pushViewController(displayVC, animated: true)
        recentDrawingBtn.isHidden = true
    }
    
    func uploadImageToFirebaseStorage(image: UIImage) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyddmm-hhmmss"
        let imgName = formatter.string(from: date)
        
        let storageRef = Storage.storage().reference(forURL: "gs://drawingapp-a9808.appspot.com/Drawings").child("Drawings").child("Img\(imgName).jpg")
        guard let uploadData = image.jpegData(compressionQuality: 0.7) else { print("Failed to get Image")
            return
        }
        
        storageRef.putData(uploadData, metadata: nil) { (storageMetadata, error) in
            if error != nil {
               self.showAlert(title: "Error", message: "Image doesnot Upload to the Firebase")
                return
            }
            if storageMetadata != nil {
                self.showAlert(title: "Success", message: "Image Uploaded to the Firebase")
                storageRef.downloadURL { (downloadImageUrl, error) in
                    guard let url = downloadImageUrl else { print("Failed to get Image Url")
                        return
                    }
                    self.saveImageInLocalStorage(imageUrl: url,imgName: imgName)
                }
            }
        }
    }
    
    func saveImageInLocalStorage(imageUrl: URL,imgName: String) {
        let fileManager = FileManager.default
        do {
            let docDirectory = try fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderUrl = docDirectory.appendingPathComponent("Drawings")
            let subFolder = folderUrl.appendingPathComponent("Img\(imgName).jpg")
            if !fileManager.fileExists(atPath: folderUrl.path) {
                try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            }
            let imageData = try Data(contentsOf: imageUrl)
            do {
                try imageData.write(to: subFolder)
            }catch {
                print("Failed to save image")
            }
        }catch {
            print("Error To save Image in local Storage")
        }
    }

    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK:- Delegate Methods -

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        canvasView.strokeColor = colors[indexPath.item]
    }
    
}

//MARK:-  DelegateFlowLayout Methods -

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 30, height: 30)
        
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}


//MARK:-  DataSource Methods -

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = colors[indexPath.item]
        return cell
        
    }
}
