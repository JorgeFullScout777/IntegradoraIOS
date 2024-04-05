//
//  LoginViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var txfCorreo: UITextField!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var viewBackgroundInputs: UIView!
    @IBOutlet weak var btnIniciarSesion: UIButton!
    @IBOutlet var btnsLogin: [UIButton]!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Blur Imagen
        /*let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imgBackground.bounds
        imgBackground.addSubview(blurEffectView)*/
        
        //Redondeo Contenedor
        viewBackgroundInputs.layer.cornerRadius = 20
        
        //Redonde Botones
        for boton in btnsLogin{
            boton.layer.cornerRadius = 20
            boton.layer.borderWidth = 4.0
            boton.layer.borderColor = btnsLogin[0].backgroundColor?.cgColor
        }
        
        txfPassword.isSecureTextEntry = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txfCorreo{
            txfPassword.becomeFirstResponder()
        }
        else{
            txfPassword.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("OK")
        
        if (txfCorreo.text)!.count > 1 && (txfPassword.text)!.count > 1 {
            btnIniciarSesion.isEnabled = true
        }
        else{
            btnIniciarSesion.isEnabled = false
        }
    }
    
    @IBAction func IniciarSesion() {
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "https://rickandmortyapi.com/api/character")!
        
        conexion.dataTask(with: url) { datos, respuesta, error in
            do{
                let json = try JSONSerialization.jsonObject(with: datos!) as! [String:Any]
                let resultados = json["results"] as! [[String:Any]]
                for personaje in resultados{
                    print(personaje)
                }
                DispatchQueue.main.async{
                    
                }
            }
            catch{
                print("Error en la peticion =(")
            }
        }.resume()
    }
    
    
}
