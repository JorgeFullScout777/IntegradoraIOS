//
//  LoginViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var imgBackground: UIImageView!
    
    @IBOutlet weak var viewBackgroundInputs: UIView!
    @IBOutlet var btnsLogin: [UIButton]!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Blur Imagen
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imgBackground.bounds
        imgBackground.addSubview(blurEffectView)
        
        //Redondeo Contenedor
        viewBackgroundInputs.layer.cornerRadius = 20
        
        //Redonde Botones
        for boton in btnsLogin{
            boton.layer.cornerRadius = 20
            boton.layer.borderWidth = 4.0
            boton.layer.borderColor = btnsLogin[0].backgroundColor?.cgColor
        }
    }

}
