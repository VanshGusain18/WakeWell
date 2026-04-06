//
//  ActivityDetailViewController.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import UIKit

class ActivityDetailViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var steps: UILabel!
    
    //here the circular timer layer is made.
    var timerLayer = CAShapeLayer()
    var backgroundLayer = CAShapeLayer()
    var timer: Timer?
    var duration: CGFloat = 10   // in seconds
    var progress: CGFloat = 0
    
    var activity: Activity? // activity is called
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // guard let activity = activity else { return }
        setupUI()
        setupData()
    }
    
    //calling the function for the circular timer
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCircularTimer()
    }
    
    func setupData() {  // the way the data will look like 
        guard let activity = activity else { return }
        
        imageView.image = UIImage(named: activity.imageName)
        let formattedSteps = activity.steps.map { "• \($0)" }.joined(separator: "\n")
           steps.text = formattedSteps
        instructionLabel.text = activity.description
        titleLabel.text = activity.title
        DispatchQueue.main.async {
            self.imageView.layer.cornerRadius = self.imageView.frame.width / 2 // makes the image circular afterwards
        }
    }
    
    @IBAction func startTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
        
        startTimer()
    }
    
    func startTimer() {
        progress = 0
        timerLayer.strokeEnd = 0
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            
            self.progress += 0.05 / self.duration
            self.timerLayer.strokeEnd = self.progress
            
            if self.progress >= 1 {
                self.timer?.invalidate()
                self.timerCompleted()
            }
        }
    }
    func timerCompleted() {
        
        UIView.animate(withDuration: 0.2) {
            self.imageView.transform = .identity
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        print("Timer Done")
    }
    
    func setupUI() { // this is the UI to set the palcing of the cards (Detailed cards)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.font = UIFont.systemFont(ofSize: 18)
        instructionLabel.textColor = .darkGray
        
        steps.translatesAutoresizingMaskIntoConstraints = false
        steps.textAlignment = .left
        steps.numberOfLines = 0
        steps.font = UIFont.systemFont(ofSize: 18)
        steps.textColor = .gray
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        startButton.layer.cornerRadius = 15
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(instructionLabel)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            
            // Image (center)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Instruction label
            instructionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            instructionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            instructionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            // steps label
            steps.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            steps.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            steps.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            // Button
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
     // the timer thinline which wil appear around teh image
    func setupCircularTimer() {
           timerLayer.removeFromSuperlayer()
           backgroundLayer.removeFromSuperlayer()
           
           let center = imageView.center
           let radius = imageView.frame.width / 2 + 15
           
           let circularPath = UIBezierPath(
               arcCenter: CGPoint(x: 0, y: 0),
               radius: radius,
               startAngle: -CGFloat.pi / 2,
               endAngle: 2 * CGFloat.pi,
               clockwise: true
           )
           backgroundLayer = CAShapeLayer()
           backgroundLayer.path = circularPath.cgPath
           backgroundLayer.strokeColor = UIColor.systemGray4.cgColor
           backgroundLayer.lineWidth = 6
           backgroundLayer.fillColor = UIColor.clear.cgColor
           backgroundLayer.position = center
           
           view.layer.addSublayer(backgroundLayer)
           
           // Progress ring
           timerLayer = CAShapeLayer()
           timerLayer.path = circularPath.cgPath
           timerLayer.strokeColor = UIColor.systemBlue.cgColor
           timerLayer.lineWidth = 6
           timerLayer.fillColor = UIColor.clear.cgColor
           timerLayer.lineCap = .round
           timerLayer.strokeEnd = 0
           timerLayer.position = center
           
           view.layer.addSublayer(timerLayer)
       }
}
