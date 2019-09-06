//
//  StreetViewController.swift
//  MyGoogleMap
//
//  Created by INVISION on 25/8/2562 BE.
//  Copyright © 2562 INVISION. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import AlamofireImage

class StreetViewController: UIViewController {

    @IBOutlet weak var mStreetView: GMSPanoramaView!
    @IBOutlet weak var mMapImageView: UIImageView!
    
    var position: CLLocationCoordinate2D! // รับค่าจาก VC ตัวแรก
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mStreetView.moveNearCoordinate(self.position)
        self.loadStaticMapImage()

    }
    
    func loadStaticMapImage() {
        // more url format to deal with map application (google and apple)
        // http://kvurd.com/blog/apple-google-open-street-map-urls-with-latitude-longitude/
        let googleAPIKey = "AIzaSyC_SI83lZv4BcFI5mgTc4yu-O_qQa76qYk"
        let mapFrame = self.mMapImageView.frame
        let mapImageUrlTmp: String = "https://maps.google.com/maps/api/staticmap?markers=color:red|\(self.position.latitude),\(self.position.longitude)&\("zoom=16&size=\(2 * Int(mapFrame.size.width))x\(2 * Int(mapFrame.size.height))")&sensor=true&key=\(googleAPIKey)"
        let mapImageUrl = mapImageUrlTmp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
       //print(mapImageUrl)
        let mapUrl = URL(string: mapImageUrl!)!
        self.mMapImageView.af_setImage(withURL: mapUrl)
    }
    
    @IBAction func onClickNavigation(){
//        print("Tap")
        let locationString = "\(position.latitude),\(position.longitude)"
        let targetURL = URL(string: "http://maps.apple.com/?z=12&q=\(locationString)")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(targetURL)
        }
    }


}
