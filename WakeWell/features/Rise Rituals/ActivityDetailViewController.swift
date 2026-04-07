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
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var steps: UILabel!
    
    //here the circular timer layer is made.
    var timerLayer = CAShapeLayer()
    var backgroundLayer = CAShapeLayer()
    var timer: Timer?
    var duration: CGFloat = 10   // in seconds
    var progress: CGFloat = 0
    var routineQueue: [Activity] = [] // The full list of selected activities
    var currentIndex: Int = 0         // Where we are in the list
    var activity: Activity? // activity is called
    let contentView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // guard let activity = activity else { return }
        setupUI()
        setupData()
        startCountdown()
        //contentView.addSubview(startButton)
    }
    
    //calling the function for the circular timer
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(contentView)
        setupCircularTimer()
    }
    
    func setupData() {
        guard let activity = activity else { return }
        
        // Existing data setup...
        titleLabel.text = activity.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        
        // Add a progress indicator in the title or a separate label
        let stepNumber = currentIndex + 1
        self.navigationItem.title = "Step \(stepNumber)/\(routineQueue.count)"
        instructionLabel.text = activity.description
        steps.text = activity.steps.map { "• \($0)" }.joined(separator: "\n")
    }
    var startTime: Date?

    func startTimer() {
        progress = 0
        timerLayer.strokeEnd = 0
        
        timer?.invalidate()
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            
            guard let startTime = self.startTime else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = elapsed / Double(self.duration)
            
            self.timerLayer.strokeEnd = min(CGFloat(progress), 1.0)
            
            if progress >= 1 {
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
        
        // Change button to show we are moving on
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.goToNextActivity()
        }
        showCompletionOverlay()
    }
    
    func goToNextActivity() {
        if currentIndex < routineQueue.count - 1 {
            // 1. Instantiate the next detail view
            let storyboard = UIStoryboard(name: "Rise", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "ActivityDetailViewController") as! ActivityDetailViewController
            
            // 2. Pass the data forward
            nextVC.routineQueue = self.routineQueue
            nextVC.currentIndex = self.currentIndex + 1
            nextVC.activity = routineQueue[currentIndex + 1]
            
            // 3. Push with a nice transition
            navigationController?.pushViewController(nextVC, animated: true)
        } else {
            // Routine is over! Go back to the deck
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func startCountdown() {
        
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .systemBackground
        overlay.alpha = 0
        view.addSubview(overlay)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .label
        
        overlay.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 1
        }
        
        var count = 3
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            if count > 0 {
                label.text = "\(count)"
                count -= 1
                
            } else if count == 0 {
                label.text = "Let's Begin"
                count -= 1
                
            } else {
                timer.invalidate()
                
                UIView.animate(withDuration: 0.4, animations: {
                    overlay.alpha = 0
                }) { _ in
                    overlay.removeFromSuperview()
                    self.startTimer()
                }
            }
        }
    }
    
    func showCompletionOverlay() {
        
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = .systemBackground
        overlay.alpha = 0
        view.addSubview(overlay)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = .label
        label.numberOfLines = 0
        
        label.text = "Great job 👏\nYou showed up today"
        
        overlay.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            label.leftAnchor.constraint(equalTo: overlay.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: overlay.rightAnchor, constant: -20)
        ])
        
        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            UIView.animate(withDuration: 0.4, animations: {
                overlay.alpha = 0
            }) { _ in
                overlay.removeFromSuperview()
                self.goToNextActivity()
            }
        }
    }
    
    func setupUI() { // this is the UI to set the palcing of the cards (Detailed cards)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        
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
        
        let timerTextLabel = UILabel()
        timerTextLabel.translatesAutoresizingMaskIntoConstraints = false
        timerTextLabel.font = UIFont.boldSystemFont(ofSize: 48)
        timerTextLabel.textAlignment = .center
        timerTextLabel.text = "\(Int(duration * (1 - progress)))"

        view.addSubview(timerTextLabel)

        NSLayoutConstraint.activate([
            timerTextLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            timerTextLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
        
        view.addSubview(imageView)
        view.addSubview(instructionLabel)
        //view.addSubview(startButton)
        view.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Image (center)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
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
//            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
//            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            startButton.widthAnchor.constraint(equalToConstant: 200),
//            startButton.heightAnchor.constraint(equalToConstant: 50)
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
        view.addSubview(imageView)
       }
}
