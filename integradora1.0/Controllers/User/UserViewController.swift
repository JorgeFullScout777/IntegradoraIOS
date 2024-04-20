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
    var alertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        btnCambiaContraseña.layer.borderWidth = 4.5
        btnCambiaContraseña.layer.borderColor = UIColor.systemGreen.cgColor
        btnCambiaContraseña.layer.cornerRadius = 20
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
                            self.lblNombreUsuario.text = User.nameUsuario
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
                        self.present(ApplicationConfiguration.closeApp(), animated: true)
                    }
                }
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async{
                        self.alertController = UIAlertController(title: "Ha ocurrido algo", message: "Porfavor, intentelo de nuevo", preferredStyle: .alert)
                        let aceptar = UIAlertAction(title: "Aceptar", style: .default)
                        self.alertController?.addAction(aceptar)
                        self.present(self.alertController!, animated: true, completion: nil)
                        }
                }
                if let data = data {
                    print(data)
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Respuesta JSON: \(jsonResponse)")
                    } catch {
                        print("Error al convertir los datos de la respuesta a JSON: \(error.localizedDescription)")
                    }
                }
            }
        }

        task.resume()
    }
    
    
}
