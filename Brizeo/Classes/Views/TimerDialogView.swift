//
//  TimerDialogView.swift
//  Brizeo
//
//  Created by Roman Bayik on 7/13/17.
//  Copyright © 2017 Kogi Mobile. All rights reserved.
//

import UIKit

class TimerDialogView: UIView {

    // MARK: - Types
    
    struct Constants {
        static let animationDuration = 0.3
        static let timerInterval = 0.1
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var backgroundView: UIView?
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.text = LocalizableString.TimerBottomText.localizedString
        }
    }
    @IBOutlet weak var topTextLabel: UILabel! {
        didSet {
            topTextLabel.text = LocalizableString.TimerTopText.localizedString
        }
    }
    
    fileprivate var timer: Timer?
    var isOkButtonEnabled = true {
        didSet {
            okButton.isEnabled = isOkButtonEnabled
        }
    }
    
    // MARK: - Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        centerView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        backgroundView?.alpha = 0.0
        
        okButton.layer.cornerRadius = 8.0
    }
    
    // MARK: - Public methods
    
    func prepareView() {
        
        startTimer()
    }
    
    // MARK: - Timer methods
    
    fileprivate func startTimer() {
        
        // check whether we need to run timer
        guard let sessionDate = ActionCounter.shared.sessionDate else {
            return
        }
        
        guard sessionDate.timeIntervalSinceNow <= Configurations.General.timeToReset else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: Constants.timerInterval, repeats: true, block: { (timer) in
            
            guard let sessionDate = ActionCounter.shared.sessionDate else {
                ActionCounter.didApprove(fromSearchController: false)
                print("No session date in action counter")
                return
            }
            
            let secondsTillReset = Configurations.General.timeToReset + sessionDate.timeIntervalSinceNow
            
            if secondsTillReset <= 0 {
                timer.invalidate()
                self.timerLabel.text = "00:00:00"
                self.removeFromSuperview()
            } else {
                
                let hours = Int(secondsTillReset) / 3600
                let minutes = Int(secondsTillReset) / 60 % 60
                let seconds = Int(secondsTillReset) % 60
                
                self.timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
            }
        })
    }
    
    // MARK: - Init methods
    
    init() {
        super.init(frame: CGRect.zero)
        
        startTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        startTimer()
    }
    
    // MARK: - Public methods
    
    func present(on view: UIView, withAnimation: Bool) {
        frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
        view.addSubview(self)
        
        if withAnimation {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.centerView.transform = CGAffineTransform.identity
                self.backgroundView?.alpha = 1.0
            }
        } else {
            self.centerView.transform = CGAffineTransform.identity
            self.backgroundView?.alpha = 1.0
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onOkButtonClicked(sender: UIButton) {
        self.removeFromSuperview()
    }
}
