//
//  PlantViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

protocol PlantViewControllerDelegate: AnyObject {
    func backButtonPressed(index:Int, planta:Planta)
    func stopPolling()
}

class PlantViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: PlantViewControllerDelegate?
    var index:Int? = nil
    var planta:Planta? = nil
    var update:Bool = false
    var color:UIColor? = nil
    var sensores:[Sensor] = []
    @IBOutlet weak var imgIsActive: UIImageView!
    @IBOutlet weak var lblNombrePlanta: UILabel!
    @IBOutlet weak var imgPlanta: UIImageView!
    @IBOutlet weak var btnEliminar: UIButton!
    @IBOutlet weak var btnEditar: UIButton!
    @IBOutlet weak var btnRegar: UIButton!
    @IBOutlet weak var lblSensorSun: UILabel!
    @IBOutlet weak var lblSensorWater: UILabel!
    @IBOutlet weak var lblSensorThermometer: UILabel!
    @IBOutlet weak var lblSensorRain: UILabel!
    @IBOutlet weak var lblSensorMovement: UILabel!
    @IBOutlet weak var lblSensorHumidity: UILabel!
    @IBOutlet weak var lblSensorVibration: UILabel!
    @IBOutlet weak var lblSensorHumidityDirt: UILabel!
    @IBOutlet weak var lblDateInfo: UILabel!
    
    var alertController:UIAlertController? = nil
    var timer:Timer? = nil
    
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
                                if self.planta?.status == false{
                                    self.btnDisabled()
                                }
                                else{
                                    self.btnEnabled()
                                }
                                self.ifPolling()
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
        timer?.invalidate()
        if update == true{
            delegate?.backButtonPressed(index: index!, planta: planta!)
        }
        dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func iniciarInterfaz(){
        if planta?.status == false{
            btnDisabled()
        }
        btnRegar.layer.cornerRadius = 25
        btnEditar.layer.cornerRadius = 25
        btnEliminar.layer.cornerRadius = 25
        dibujarValoresPlanta()
        ifPolling()
        
    }
    
    func ifPolling(){
        if planta?.status == true{
            pollingData()
            timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(pollingData), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        }
        else{
            timer?.invalidate()
            lblDateInfo.text = "Desactivado"
            lblSensorSun.text = "0"
            lblSensorWater.text = "0"
            lblSensorThermometer.text = "0"
            lblSensorRain.text = "0"
            lblSensorMovement.text = "0"
            lblSensorHumidity.text = "0"
            lblSensorVibration.text = "0"
            lblSensorHumidityDirt.text = "0"
        }
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
                        if httpResponse.statusCode == 401{
                            DispatchQueue.main.async{
                                self.present(ApplicationConfiguration.login(), animated: true)
                            }
                        }
                        if httpResponse.statusCode == 422 {
                            if let errors = jsonResponse["errors"] as? [String: [String]]{
                                DispatchQueue.main.async{
                                    self.alertController = UIAlertController(title: "Ha ocurrido algo", message: errors["plant"]?.first, preferredStyle: .alert)
                                    let aceptar = UIAlertAction(title: "Aceptar", style: .default)
                                    self.alertController?.addAction(aceptar)
                                    self.present(self.alertController!, animated: true, completion: nil)
                                    }
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
    
    @objc func pollingData(){
        print("Haciendo polling ...")
        if let token = UserDefaults.standard.string(forKey: "token"){
            let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/websocket/ios/last")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let datos = json as? [String: Any] {
                            if let httpResponse = response as? HTTPURLResponse {
                                print("Código de estado HTTP de la respuesta: \(httpResponse.statusCode)")
                                if httpResponse.statusCode == 200{
                                    print("Estado 200")
                                    self.sensores.removeAll()
                                    for sensor in datos["data"] as! [String:Any]{
                                        if let valores = sensor.value as? [String:Any]{
                                            let name = sensor.key
                                            let date = valores["Fecha"] as! String
                                            let unit = valores["Unidad"] as! String
                                            let value = valores["Valor"] as! NSNumber
                                            let sens = Sensor(name: name, date: date, unit: unit, value: value.intValue)
                                            self.sensores.append(sens)
                                        }
                                    }
                                    self.dibujarDatos()
                                }
                                if httpResponse.statusCode == 401{
                                    print("Estado 401")
                                    DispatchQueue.main.async {
                                        self.timer!.invalidate()
                                        self.dismiss(animated: true)
                                        self.delegate?.stopPolling()
                                    }
                                }
                                
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                else{
                    print("Error al tratar de desempaquetar la respuesta de la solicitud")
                }
            }
            task.resume()
        }
        else{
            DispatchQueue.main.async {
                let login = LoginViewController()
                self.present(login, animated: true, completion: nil)
            }
        }
    }
    
    func dibujarDatos(){
        for sensor in sensores{
            switch sensor.name {
            case "Luz":
                if sensor.value <= 75{
                    DispatchQueue.main.async {
                        self.lblSensorSun.text = "Poca luz"
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.lblSensorSun.text = "Buena luz"
                    }
                }
                break;
            case "Agua":
                if sensor.value <= 50{
                    DispatchQueue.main.async {
                        self.lblSensorWater.text = "Poca agua"
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.lblSensorWater.text = "Buena cantidad"
                    }
                }
                break;
            case "Temperatura":
                DispatchQueue.main.async {
                    self.lblSensorThermometer.text = "\(sensor.value) \(sensor.unit)"
                }
                break;
            case "Lluvia":
                if sensor.value <= 0{
                    DispatchQueue.main.async {
                        self.lblSensorRain.text = "Lloviendo"
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.lblSensorRain.text = "Sin lluvia"
                    }
                }
                break;
            case "Movimiento":
                if sensor.value == 1{
                    DispatchQueue.main.async {
                        self.lblSensorMovement.text = "Movimiento det."
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.lblSensorMovement.text = "Sin movimiento"
                    }
                }
                break;
            case "Humedad":
                DispatchQueue.main.async {
                    self.lblSensorHumidity.text = "\(sensor.value) \(sensor.unit)"
                }
                break;
            case "Vibracion":
                if sensor.value == 1{
                    DispatchQueue.main.async {
                        self.lblSensorVibration.text = "Vibrando"
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.lblSensorVibration.text = "Sin vibración"
                    }
                }
                break;
            case "Suelo":
                if sensor.value <= 50{
                    DispatchQueue.main.async {
                        self.lblSensorHumidityDirt.text = "Suelo seco"
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.lblSensorHumidityDirt.text = "Suelo húmedo"
                    }
                }
                break;
            default:
                print("Algo ha ocurrido mientras se dibujaban los datos de los sensores")
                break;
            }
        }
        DispatchQueue.main.async{
            self.lblDateInfo.text = self.sensores[0].date
        }
    }
    
    func btnEnabled(){
        btnRegar.isEnabled = true
        btnRegar.alpha = 1
    }
    
    func btnDisabled(){
        btnRegar.isEnabled = false
        btnRegar.alpha = 0.5
    }
    
    @IBAction func actionRegar() {
        if planta?.status == true{
            btnDisabled()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.btnEnabled()
            }
            if let token = UserDefaults.standard.string(forKey: "token"){
                let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/websocket/bomb")!
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            print("Hay respuesta")
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            print("Respuesta JSON: \(json)")
                            if let datos = json as? [String: Any] {
                                print("Datos: \(datos)")
                                if let httpResponse = response as? HTTPURLResponse {
                                    if httpResponse.statusCode == 200{
                                        print("Estado 200 Regado de Planta")
                                        DispatchQueue.main.async {
                                            self.alertController = UIAlertController(title: "Exito", message: "Se esta regando la planta", preferredStyle: .alert)
                                            let aceptar = UIAlertAction(title: "Aceptar", style: .default)
                                            self.alertController?.addAction(aceptar)
                                            self.present(self.alertController!, animated: true)
                                        }
                                    }
                                    if httpResponse.statusCode == 401{
                                        self.present(ApplicationConfiguration.closeApp(), animated: true)
                                    }
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                    else{
                        print("Error al tratar de desempaquetar la respuesta de la solicitud")
                    }
                }
                task.resume()
            }
            else{
                DispatchQueue.main.async {
                    let login = LoginViewController()
                    self.present(login, animated: true, completion: nil)
                }
            }
        }
    }
    
}
