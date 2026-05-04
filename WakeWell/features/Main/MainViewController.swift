//
//  HomeViewController.swift
//  WakeWell
//
//  Created by geu on 07/02/26.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var here: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func but(_ sender: Any) {
        here.text = "Hello"
    }

}
