//
//  ShapeViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class ShapeViewController: UIViewController {

    @IBOutlet var viewSelectPortion:UIView!
    @IBOutlet var btnDone:UIButton!
    
    public var selectedSong:SongInfo! = nil
    
    var cropVC:IQAudioCropperViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        
        btnDone.layer.borderColor = UIColor(red: 255/255.0, green: 4/255.0, blue: 22/255.0, alpha: 1.0).cgColor
        btnDone.layer.borderWidth = 3
        btnDone.layer.cornerRadius = btnDone.frame.size.width/2
        btnDone.layer.masksToBounds = true
        btnDone.isHidden = true

        addCropMusicView()        

        self.navigationController?.isToolbarHidden = false
    }
    
    func addCropMusicView() {
                
        if let filePath = self.selectedSong.songUrl as URL? {
            cropVC = IQAudioCropperViewController(fileUrl: filePath)
            cropVC.delegate = self
            cropVC.parentVC = self
            cropVC.frameView = self.viewSelectPortion.bounds
            
            self.addChildViewController(cropVC)
            self.viewSelectPortion.addSubview(cropVC.view)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.isToolbarHidden = true
        
        cropVC.stopPlayingButtonAction(nil)
        cropVC.view.removeFromSuperview()
        cropVC.removeFromParentViewController()
    }

    @IBAction func onClickedCheckDone(_ sender: Any) {
        cropVC.notifySuccessDelegate()
    }
    
}

extension ShapeViewController: IQAudioCropperViewControllerDelegate {
    
    func audioCropperController(_ controller: IQAudioCropperViewController, didFinishWithAudioAtPath filePath: String) {
        
        UserDefaults.standard.set(filePath, forKey: "selected_song")
        UserDefaults.standard.synchronize()
        
        self.navigationController?.isToolbarHidden = true
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
    }
    
    func audioCropperControllerDidCrop(_ controller: IQAudioCropperViewController) {
        self.btnDone.isHidden = false
    }
    
}
