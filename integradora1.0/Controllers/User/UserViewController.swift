//
//  UserViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 18/04/24.
//

import UIKit

class UserViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var btnCambiaContraseña: UIButton!
    @IBOutlet weak var lblCountPlantas: UILabel!
    @IBOutlet weak var lblNombreUsuario: UILabel!
    @IBOutlet weak var lblCorreoUsuario: UILabel!
    @IBOutlet weak var btnCerrarSesion: UIButton!
    var alertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        btnCambiaContraseña.layer.cornerRadius = 25
        btnCerrarSesion.layer.cornerRadius = 25
        getUser()
    }
    
    func getUser() {
        let session = URLSession.shared
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/auth/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud POST: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de estado HTTP de la respuesta: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 401{
                    DispatchQueue.main.async{
                        self.present(ApplicationConfiguration.closeApp(), animated: true)
                    }
                }
                if let data = data {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                        DispatchQueue.main.async{
                            User.emailUsuario = json["email"] as? String
                            User.nameUsuario = json["name"] as? String
                            User.plantsCount = json["plant_count"] as? Int
                            self.lblNombreUsuario.text = User.nameUsuario!
                            self.lblCorreoUsuario.text = User.emailUsuario!
                            if let texto = User.plantsCount{
                                self.lblCountPlantas.text = String(User.plantsCount!)
                            }
                        }
                    }
                    catch{
                        print("Error en la peticion =(")
                    }
                }
            }
        }
        task.resume()
    }

    @IBAction func changePassword() {
        alertController = UIAlertController(title: "Cambiar contraseña", message: nil, preferredStyle: .alert)
        
        alertController?.addTextField { (textField) in
            textField.placeholder = "Contraseña ..."
            textField.returnKeyType = .done
            textField.isSecureTextEntry = true
            textField.delegate = self
            
        }
        let aceptarAction = UIAlertAction(title: "Confirmar", style: .default) { accion in
            if let texto = self.alertController?.textFields?.first?.text {
                self.cambiarContraseña(contraseña: texto)
            }
        }
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel) { accion in
            if let alertController = self.alertController {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
        alertController?.addAction(aceptarAction)
        alertController?.addAction(cancelarAction)
        present(alertController!, animated: true, completion: nil)
    }
    
    func cambiarContraseña(contraseña:String){
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/auth/changepassword")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token")!)"]
        let parameters: [String: Any] = [
            "password": contraseña
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print("Error al convertir los parámetros a JSON: \(error.localizedDescription)")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud POST: \(error.localizedDescription)")
                return
            }
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Respuesta JSON: \(jsonResponse)")
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Código de estado HTTP de la respuesta: \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 200{
                            DispatchQueue.main.async{
                                self.alertController = UIAlertController(title: "Contraseña cambiada", message: "La contraseña se ha actualizado", preferredStyle: .alert)
                                let aceptar = UIAlertAction(title: "Aceptar", style: .default)
                                self.alertController?.addAction(aceptar)
                                self.present(self.alertController!, animated: true, completion: nil)
                                }
                        }
                        if httpResponse.statusCode == 401{
                            DispatchQueue.main.async{
                                let alerta = UIAlertController(title: "Ha ocurrido algo", message: "Vuelve a iniciar sesion", preferredStyle: .alert)
                                let aceptar = UIAlertAction(title: "Aceptar", style: .default){accion in
                                    self.present(ApplicationConfiguration.login(), animated: true)
                                }
                                alerta.addAction(aceptar)
                                self.present(alerta, animated: true)
                            }
                        }
                        if httpResponse.statusCode == 422 {
                            if let responseDictionary = jsonResponse as? [String: Any]{
                                let errors = responseDictionary["errors"] as! [String: [String]]
                                DispatchQueue.main.async{
                                    self.alertController = UIAlertController(title: "Ha ocurrido algo", message: errors["password"]?.first, preferredStyle: .alert)
                                    let aceptar = UIAlertAction(title: "Aceptar", style: .default)
                                    self.alertController?.addAction(aceptar)
                                    self.present(self.alertController!, animated: true, completion: nil)
                                    }
                            }
                        }
                    }
                } catch {
                    print("Error al convertir los datos de la respuesta a JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    @IBAction func CerrarSesion() {
        alertController = UIAlertController(title: "Cerrar sesión", message: "¿Estás seguro de cerrar sesión?", preferredStyle: .alert)
        let aceptarAction = UIAlertAction(title: "Sí", style: .default) { accion in
            self.logout()
        }
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel) { accion in
            if let alertController = self.alertController {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
        alertController?.addAction(aceptarAction)
        alertController?.addAction(cancelarAction)
        present(alertController!, animated: true, completion: nil)
    }
    
    func logout() {
        
            let conexion = URLSession(configuration: .default)
            let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/auth/logout")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
            conexion.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error en la solicitud POST: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("Código de estado HTTP de la respuesta: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200{
                        print("Sesión cerrada")
                        DispatchQueue.main.async{
                            self.present(ApplicationConfiguration.login(), animated: true)
                        }
                    }
                    if httpResponse.statusCode == 401{
                        DispatchQueue.main.async{
                            self.present(ApplicationConfiguration.closeApp(), animated: true)
                        }
                    }
                    if let data = data {
                        do{
                            let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                        }
                        catch{
                            print("Error en la peticion =(")
                        }
                    }
                }
            }.resume()
    }
    
}
