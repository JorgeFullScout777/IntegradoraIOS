//
//  PlantsViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

class PlantsViewController: UIViewController {

    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgPlant: UIImageView!
    @IBOutlet weak var viewContainerPlant: UIView!
    @IBOutlet weak var btnSeePlant: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imgBackground.bounds
        imgBackground.addSubview(blurEffectView)
        
        
        btnSeePlant.layer.cornerRadius = 25
        imgPlant.layer.cornerRadius = 10
        viewContainerPlant.layer.cornerRadius = 20
        viewContainerPlant.layer.borderWidth = 2
        viewContainerPlant.layer.borderColor = UIColor.black.cgColor
    }

}
