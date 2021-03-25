//
//  StereoViewController.swift
//  Stereo
//
//  Created by Phil Stern on 3/25/21.
//

import UIKit

struct Constants {
    static let frameTime = 0.02  // seconds
    static let rotationPeriod = 4.0  // seconds per 360 degree rotation
}

class StereoViewController: UIViewController {

    var rotation = 0.0
    
    private var simulationTimer = Timer()
    
    @IBOutlet weak var stereoView: StereoView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSimulation()
    }

    private func startSimulation() {
        simulationTimer = Timer.scheduledTimer(timeInterval: Constants.frameTime, target: self,
                                               selector: #selector(updateSimulation),
                                               userInfo: nil, repeats: true)
    }
    
    @objc func updateSimulation() {
        let deltaAngle = Constants.frameTime / Constants.rotationPeriod * 360  // degrees
        rotation = (rotation + deltaAngle).truncatingRemainder(dividingBy: 360)
        stereoView.rotation = CGFloat(rotation)
    }
}
