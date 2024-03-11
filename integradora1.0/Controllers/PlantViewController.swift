//
//  PlantViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

class PlantViewController: UIViewController {

    @IBOutlet weak var scrPlantDetails: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrPlantDetails.contentSize = CGSize(width: 0, height: 597)
    }

}
