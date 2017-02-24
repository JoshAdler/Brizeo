//
//  ParticipantView.swift
//  Brizeo
//
//  Created by Giovanny Orozco on 4/21/16.
//  Copyright © 2016 Kogi Mobile. All rights reserved.
//

import AlamofireImage

class ParticipantView: UIView {
    
    @IBOutlet weak fileprivate var userImageView: UIImageView!
    @IBOutlet weak fileprivate var userNameLabel: UILabel!
    
    var actionBlock: ((_ sender: ParticipantView) -> Void)?
    
    class func participantView(imageUrl url: URL?, userName: String?) -> ParticipantView {
    
        let view = UINib(nibName: String(describing: ParticipantView.self), bundle: nil).instantiate(withOwner: self, options: nil).first! as! ParticipantView
        
        if let url = url {
            view.userImageView.af_setImage(withURL: url)
        }
        
        view.userNameLabel.text = userName
        
        let size = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        var frame = view.frame
        frame.size = size
        frame.origin = CGPoint(x: UIScreen.main.bounds.width / 2 - (size.width / 2), y: 5)
        view.frame = frame
        
        return view
    }
    
    @IBAction fileprivate func userButtonPressed(_ sender: UIButton) {
    
        if let actionBlock = actionBlock {
            actionBlock(self)
        }
    }
}
