//
//  PlantViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

protocol PlantViewControllerDelegate: AnyObject {
    func backButtonPressed(index:Int, planta:Planta)
}

class PlantViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: PlantViewControllerDelegate?
    var index:Int? = nil
    var planta:Planta? = nil
    var update:Bool = false
    var color:UIColor? = nil
    @IBOutlet weak var imgIsActive: UIImageView!
    @IBOutlet weak var lblNombrePlanta: UILabel!
    @IBOutlet weak var imgPlanta: UIImageView!
    @IBOutlet weak var btnEliminar: UIButton!
    @IBOutlet weak var btnEditar: UIButton!
    @IBOutlet weak var btnRegar: UIButton!
    var alertController:UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        color = imgIsActive.tintColor
        iniciarInterfaz()
    }
    
    @IBAction func deletePlant() {
        let session = URLSession.shared
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/plants/destroy/\(planta!.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
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
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                        print("Respuesta JSON: \(jsonResponse["data"]!)")
                        let datos = jsonResponse["data"] as! [String:Any]
                        if httpResponse.statusCode == 200{
                            DispatchQueue.main.async{
                                self.update = true
                                self.planta?.status = datos["status"] as! Bool
                                self.iconIsActive()
                            }
                        }
                    } catch {
                        print("Error al convertir los datos de la respuesta a JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
    }
    
    func iconIsActive(){
        if planta?.status == true{
            imgIsActive.tintColor = color
            btnEliminar.backgroundColor = .systemRed
        }
        else{
            imgIsActive.tintColor = .systemRed
            btnEliminar.backgroundColor = .systemGreen
        }
    }
    
    @IBAction func btnBack() {
        if update == true{
            delegate?.backButtonPressed(index: index!, planta: planta!)
        }
        dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func iniciarInterfaz(){
        btnRegar.layer.cornerRadius = 25
        btnEditar.layer.cornerRadius = 25
        btnEliminar.layer.cornerRadius = 25
        dibujarValoresPlanta()
    }
    
    func dibujarValoresPlanta(){
        lblNombrePlanta.text = planta?.name
        imgPlanta.image = planta?.image
        iconIsActive()
    }
    

    @IBAction func updatePlanta() {
        alertController = UIAlertController(title: "Cambiar nombre", message: nil, preferredStyle: .alert)
        
        alertController?.addTextField { (textField) in
            textField.placeholder = "Nombre ..."
            textField.returnKeyType = .done
            textField.delegate = self
        }
        let aceptarAction = UIAlertAction(title: "Aceptar", style: .default) { accion in
            if let texto = self.alertController?.textFields?.first?.text {
                self.actualizarPlanta(name: texto)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func actualizarPlanta(name:String){
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/plants/update/\(planta!.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token")!)"]
        let parameters: [String: Any] = [
            "plant": name,
            "status": planta!.status,
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
                if httpResponse.statusCode == 401{
                    DispatchQueue.main.async{
                        self.present(ApplicationConfiguration.closeApp(), animated: true)
                    }
                }
                if let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                        print("Respuesta JSON: \(jsonResponse)")
                        if httpResponse.statusCode == 200{
                            let datos = jsonResponse["data"] as! [String:Any]
                            DispatchQueue.main.async{
                                self.update = true
                                self.lblNombrePlanta.text = datos["plant"] as? String
                                self.planta?.name = datos["plant"] as! String
                            }
                        }
                        if httpResponse.statusCode == 422 {
                            DispatchQueue.main.async{
                                self.alertController = UIAlertController(title: "Ha ocurrido algo", message: "Nombre invalido", preferredStyle: .alert)
                                let aceptar = UIAlertAction(title: "Aceptar", style: .default)
                                self.alertController?.addAction(aceptar)
                                self.present(self.alertController!, animated: true, completion: nil)
                                }
                        }
                    } catch {
                        print("Error al convertir los datos de la respuesta a JSON: \(error.localizedDescription)")
                    }
                }
            }
        }
        task.resume()
    }
    

}
