//
//  PlantViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 10/03/24.
//

import UIKit

class PlantViewController: UIViewController {

    var planta:Planta? = nil
    @IBOutlet weak var lblNombrePlanta: UILabel!
    @IBOutlet weak var imgPlanta: UIImageView!
    @IBOutlet weak var btnEliminar: UIButton!
    @IBOutlet weak var btnEditar: UIButton!
    @IBOutlet weak var btnRegar: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnRegar.layer.cornerRadius = 25
        btnEditar.layer.cornerRadius = 25
        btnEliminar.layer.cornerRadius = 25
        
        lblNombrePlanta.text = planta?.name
        imgPlanta.image = planta?.image

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func btnBack() {
        dismiss(animated: true)
    }
    

}
