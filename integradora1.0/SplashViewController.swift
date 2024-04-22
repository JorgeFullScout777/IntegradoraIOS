//
//  SplashViewController.swift
//  integradora1.0
//
//  Created by Jorge Luna Reyna on 20/04/24.
//

import UIKit
import AVFoundation

class SplashViewController: UIViewController {
    var player: AVPlayer?
    var pass:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VerifySesion()
        guard let videoURL = Bundle.main.url(forResource: "plantSplash", withExtension: "mp4") else {
            return
        }
        player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        player?.isMuted = true
        player?.pause()
        player?.play()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            if self!.pass == true {
                print(self!.pass)
                if let tbvc = self?.storyboard?.instantiateViewController(withIdentifier: "TabBar") as? TabBarOptionsViewController {
                    print("Pasa a pantalla")
                    tbvc.modalPresentationStyle = .fullScreen
                    tbvc.modalTransitionStyle = .crossDissolve
                    self!.present(tbvc, animated: true)
                }
            }
            else{
                print(self!.pass)
                DispatchQueue.main.async{
                    if let lvc = self!.storyboard?.instantiateViewController(withIdentifier: "loginView") as? LoginViewController {
                        print("Pasa a login")
                        lvc.modalPresentationStyle = .fullScreen
                        lvc.modalTransitionStyle = .crossDissolve
                        self!.present(lvc, animated: true)
                    }
                }            }
            print("salio del if")
        }
    }
    
    
    func VerifySesion(){
        
        if let token = UserDefaults.standard.string(forKey: "token"){
            if token != ""{
                let url = URL(string: "http://\(ApplicationConfiguration.direccionIP)/api/auth/me")!
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let _ = json as? [String: Any] {
                                if let httpResponse = response as? HTTPURLResponse {
                                    if httpResponse.statusCode == 200{
                                        print("Estado 200")
                                        self.pass = true
                                    }

                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
                task.resume()
            }
            else{
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "loginView")
                    controller.modalTransitionStyle = .crossDissolve
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        else{
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "loginView")
                controller.modalTransitionStyle = .crossDissolve
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
}
