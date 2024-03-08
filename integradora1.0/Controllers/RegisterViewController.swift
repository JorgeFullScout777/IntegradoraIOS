//
//  RegisterViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 08/03/24.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var scrRegister: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrRegister.contentSize = CGSize(width: 0, height: 548)
    }
    


}
