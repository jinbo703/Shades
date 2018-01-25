//
//  UIViewController+Add.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

extension UIViewController {

    func showMessage(_ msg:String) {
        
        let alert = UIAlertController(title: nil,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) {
            
        }
    }
    
    @objc func hideProgressDialog() {
        SVProgressHUD.dismiss()
    }
    
    func getDateString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMMM dd"
        let curDate = dateFormatter.string(from: NSDate() as Date)
        return curDate.uppercased()
    }
    
    func fetchImageDataAtURL(_ photoURL: String?, forImageView iv: UIImageView?) {
        
        if photoURL == nil || (photoURL?.characters.count)! < 1 {
            return
        }
        
        let filename = NSString(string: photoURL!).lastPathComponent
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let filePath = path?.appendingFormat("/%@", filename)
        if let data = NSData(contentsOfFile: filePath!) {
            
            if iv != nil {
                iv?.image = UIImage(data: data as Data)
                iv?.setNeedsDisplay()
            }
            return
        }
        
        SVProgressHUD.show()
        let globlQueue = DispatchQueue.global()
        globlQueue.async {
            
            let storageRef = Storage.storage().reference(forURL: photoURL!)
            storageRef.getData(maxSize: INT64_MAX, completion: { (data, error) in
                
                if let error = error {
                    print("Error downloading image data: \(error)")
                    SVProgressHUD.dismiss()
                    return
                }
                
                storageRef.getMetadata(completion: { (metadata, metadataErr) in
                    
                    if let error = metadataErr {
                        print("Error downloading metadata: \(error)")
                        SVProgressHUD.dismiss()
                        return
                    }
                    if iv != nil {
                        iv?.image = UIImage.init(data: data!)
                        iv?.setNeedsDisplay()
                    }
                    
                    do {
                        try data?.write(to: URL(fileURLWithPath: filePath!))
                    } catch {
                        
                    }
                    SVProgressHUD.dismiss()
                })
            })
        }
    }
    
    func fetchImageDataAtURL(_ photoURL: String?, forButton btn: UIButton?) {
        
        if photoURL == nil || (photoURL?.characters.count)! < 1 {
            return
        }
        
        let filename = NSString(string: photoURL!).lastPathComponent
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let filePath = path?.appendingFormat("/%@", filename)
        if let data = NSData(contentsOfFile: filePath!) {
            
            if btn != nil {
                let image = UIImage(data: data as Data)
                btn?.setBackgroundImage(image, for: UIControlState.normal)
                btn?.setNeedsDisplay()
            }
            return
        }
        
        SVProgressHUD.show()
        let globlQueue = DispatchQueue.global()
        globlQueue.async {
            
            let storageRef = Storage.storage().reference(forURL: photoURL!)
            storageRef.getData(maxSize: INT64_MAX, completion: { (data, error) in
                
                if let error = error {
                    print("Error downloading image data: \(error)")
                    SVProgressHUD.dismiss()
                    return
                }
                
                storageRef.getMetadata(completion: { (metadata, metadataErr) in
                    
                    if let error = metadataErr {
                        print("Error downloading metadata: \(error)")
                        SVProgressHUD.dismiss()
                        return
                    }
                    if btn != nil {
                        let image = UIImage.init(data: data!)
                        btn?.setBackgroundImage(image, for: UIControlState.normal)
                        btn?.setNeedsDisplay()
                    }
                    
                    do {
                        try data?.write(to: URL(fileURLWithPath: filePath!))
                    } catch {
                        
                    }
                    SVProgressHUD.dismiss()
                })
            })
        }
    }
    
}
