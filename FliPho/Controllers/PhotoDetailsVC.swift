//
//  PhotoDetailsVC.swift
//  FliPho
//
//  Created by Petre Vane on 30/08/2019.
//  Copyright © 2019 Petre Vane. All rights reserved.
//

import UIKit

class PhotoDetailsVC: UIViewController {
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self

        
        imageView.image = selectedImage
        
        scrollViewProperties()
    }
    
}

extension PhotoDetailsVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewProperties() {
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3
        scrollView.zoomScale = 1
    }
}
