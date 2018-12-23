//
//  PhotoDetailViewController.swift
//  MVVMPlayground
//
//  Created by Neo on 03/10/2017.
//  Copyright © 2017 ST.Huang. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

class BaseVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {}
}

class PhotoDetailViewController: BaseVC {

    var imageUrl: String?
    lazy var imageView: UIImageView = {
        var iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageUrl = imageUrl {
            imageView.sd_setImage(with: URL(string: imageUrl)) { (image, error, type, url) in
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        imageView.image = nil
    }

    override func setupViews() {
        super.setupViews()
        
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
    }

}
