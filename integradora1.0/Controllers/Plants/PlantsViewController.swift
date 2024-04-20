//
//  PlantsViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

class PlantsViewController: UIViewController, UITextFieldDelegate, PlantViewControllerDelegate{

    var plantLabels: [UILabel] = []
    var plantViews: [UIView] = []
    @IBOutlet weak var scrPlants: UIScrollView!
    @IBOutlet weak var btnAddPlant: UIButton!
    @IBOutlet weak var imgBackground: UIImageView!
    var alertController: UIAlertController?
    var y = 10.0
    let x = 10.0
    let h = 100.0
    let k = 20.0
    var ic = 0
    /*
    @IBOutlet weak var imgPlant: UIImageView!
    @IBOutlet weak var viewContainerPlant: UIView!
    @IBOutlet weak var btnSeePlant: UIButton!*/
    var plantas:[Planta] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imgBackground.bounds
        imgBackground.addSubview(blurEffectView)
        
        btnAddPlant.layer.cornerRadius = 35
        consultarPlantas()
    }
    
    func backButtonPressed(index:Int, planta:Planta) {
        plantLabels[index].text = planta.name
        plantas[index] = planta
        print(planta.status)
        if planta.status == true{
            plantViews[index].layer.borderColor = UIColor.systemGreen.cgColor
            plantViews[index].layer.backgroundColor = UIColor.white.cgColor
        }
        else{
            plantViews[index].layer.borderColor = UIColor.systemRed.cgColor
            plantViews[index].layer.backgroundColor = UIColor(red: 255/255, green: 247/255, blue: 247/255, alpha: 1.0).cgColor
        }
    }

    func scrollPlantas(){
        scrPlants.contentSize = CGSize(width: view.frame.width, height: y+80)
    }
    
    func consultarPlantas(){
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/plants/index")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        conexion.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error en la solicitud GET: \(error.localizedDescription)")
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
                        if let resultados = json["data"] as? [[String:Any]]{
                            for planta in resultados{
                                self.plantas.append(Planta(id:planta["id"] as! Int, name: planta["plant"] as! String, status: planta["status"] as! Bool, image: nil))
                            }
                            DispatchQueue.main.async{
                                self.dibujarPlantas()
                            }
                        }
                        else{
                            print("No estas autorizado")
                        }

                    }
                    catch{
                        print("Error en la peticion =(")
                    }
                }
            }
        }.resume()
    }
    
    func dibujarPlantas(){
        let w = view.frame.width

        for (index, planta) in plantas.enumerated(){
            let vista = UIView(frame: CGRect(x: x, y: y, width: w-20.0, height: h))
            vista.backgroundColor = .white
            vista.layer.cornerRadius = 40
            vista.layer.borderWidth = 3.0

            if planta.status == true{
                vista.layer.borderColor = UIColor.systemGreen.cgColor
            }
            else{
                vista.backgroundColor = UIColor(red: 255/255, green: 247/255, blue: 247/255, alpha: 1.0)
                vista.layer.borderColor = UIColor.systemRed.cgColor
            }
            
            plantViews.append(vista)
            
            y += vista.frame.height + 10.0
            
            let num = Int.random(in: 1...4)
            let imgPlanta = UIImageView(frame: CGRect(x: 5, y: 5, width: h-10.0, height: h-10.0))
            let image = UIImage(named: "plantaset\(num).jpeg")
            imgPlanta.image = image
            planta.image = image
            imgPlanta.layer.cornerRadius = 40
            imgPlanta.clipsToBounds = true

            let lblPlanta = UILabel(frame: CGRect(x: imgPlanta.frame.origin.x+imgPlanta.frame.width+15.0, y: 5, width: vista.frame.width-imgPlanta.frame.width-40.0, height: imgPlanta.frame.height/2))
            lblPlanta.text = planta.name
            lblPlanta.font = .systemFont(ofSize: 18, weight: .regular)
            lblPlanta.adjustsFontSizeToFitWidth = true
            lblPlanta.minimumScaleFactor = 0.7
            plantLabels.append(lblPlanta)

            for i in 1...8{
                let icon = UIImageView(frame: CGRect(x: imgPlanta.frame.origin.x+imgPlanta.frame.width+15.0+CGFloat(ic), y: imgPlanta.frame.height-lblPlanta.frame.height+10.0, width: k, height: k))
                icon.contentMode = .scaleAspectFit
                icon.layer.cornerRadius = 10
                icon.layer.borderWidth = 1.5
                ic += 30
                icon.clipsToBounds = true
                switch(i){
                case 1:
                    icon.image = UIImage(systemName: "sun.max.fill")
                    icon.tintColor = .systemYellow
                    break;
                case 2:
                    icon.image = UIImage(systemName: "humidity.fill")
                    icon.tintColor = .systemBlue
                    break;
                case 3:
                    icon.image = UIImage(systemName: "thermometer.medium")
                    icon.tintColor = .red
                    break;
                case 4:
                    icon.image = UIImage(systemName: "cloud.rain.fill")
                    icon.tintColor = .systemBlue
                    break;
                case 5:
                    icon.image = UIImage(systemName: "water.waves")
                    icon.tintColor = .blue
                    break;
                case 6:
                    icon.image = UIImage(systemName: "figure.walk.motion")
                    icon.tintColor = .systemPurple
                    break;
                case 7:
                    icon.image = UIImage(named: "icondirt.jpeg")
                    icon.tintColor = .systemYellow
                    break;
                case 8:
                    icon.image = UIImage(named: "iconvibration.jpeg")
                    icon.tintColor = .systemYellow
                    break;
                default:
                    break;
                }
                icon.layer.borderColor = UIColor.systemGreen.cgColor
                vista.addSubview(icon)

            }
            
            ic = 0
            
            let btnPlanta = UIButton(frame: CGRect(x: 0, y: 0, width: vista.frame.width, height: vista.frame.height))
            btnPlanta.tag = index
            btnPlanta.addTarget(self, action: #selector(irDetalle(sender: )), for: .touchUpInside)

            vista.addSubview(btnPlanta)
            vista.addSubview(lblPlanta)
            vista.addSubview(imgPlanta)
            scrPlants.addSubview(vista)
        }
        scrollPlantas()
    }
    
    @objc func irDetalle(sender: UIButton) {
        let planta = plantas[sender.tag]
        if let pvc = storyboard?.instantiateViewController(withIdentifier: "plantView") as? PlantViewController {
            pvc.planta = planta
            pvc.index = sender.tag
            pvc.modalPresentationStyle = .fullScreen
            pvc.delegate = self
            present(pvc, animated: true)
        }
    }

    @IBAction func AddPlant() {
        
        alertController = UIAlertController(title: "Añadir una planta", message: nil, preferredStyle: .alert)
        
        alertController?.addTextField { (textField) in
            textField.placeholder = "Nombre ..."
            textField.returnKeyType = .done
            textField.delegate = self
            
        }
        let aceptarAction = UIAlertAction(title: "Aceptar", style: .default) { accion in
            if let texto = self.alertController?.textFields?.first?.text {
                self.insertarPlanta(name: texto)
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
    
    func insertarPlanta(name:String){
        let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/v1/plants/store")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "token")!)"]
        let parameters: [String: Any] = [
            "plant": name
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
                if httpResponse.statusCode == 201{
                    DispatchQueue.main.async{
                        self.clearPlants()
                    }
                    self.consultarPlantas()
                }
                if httpResponse.statusCode == 401{
                    DispatchQueue.main.async{
                        self.present(ApplicationConfiguration.closeApp(), animated: true)
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
                if let data = data {
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
    
    func clearPlants(){
        plantas.removeAll()
        y = 10.0
        for subview in self.scrPlants.subviews {
            subview.removeFromSuperview()
        }
    }

}
