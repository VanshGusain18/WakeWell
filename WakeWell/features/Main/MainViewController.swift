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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func but(_ sender: Any) {
        here.text = "Hello"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
