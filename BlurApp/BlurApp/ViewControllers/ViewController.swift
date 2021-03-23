//
//  ViewController.swift
//  BlurApp
//
//  Created by Stepan Ostapenko on 22.03.2021.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    var blurEffectView: UIVisualEffectView?
    
    private let imageSet = ["iceland", "jungle", "rocket", "sunset", "waterFall"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let selectedImageIndex = Int(arc4random_uniform(UInt32(imageSet.count)))
        print(selectedImageIndex)
        backgroundImageView.image = UIImage(named: imageSet[selectedImageIndex])
        backgroundImageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        blurEffectView?.frame = view.bounds
    }
    
}

