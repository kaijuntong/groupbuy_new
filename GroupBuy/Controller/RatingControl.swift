//
//  RatingControl.swift
//  GroupBuy
//
//  Created by KaiJun Tong on 30/10/2017.
//  Copyright © 2017 KaiJun Tong. All rights reserved.
//

import UIKit
import Firebase

protocol RatingControlDelegate:class{
    func ratingPicker(_ picker:RatingControl, didPick rating: Int)
}

@IBDesignable class RatingControl: UIStackView {
    weak var delegate:RatingControlDelegate?
    
    var ref:DatabaseReference!
    let userID:String? = Auth.auth().currentUser?.uid
    
    @IBInspectable var starSize:CGSize = CGSize(width: 44.0, height: 44.0){
        didSet{
            setupButtons()
        }
    }
    
    @IBInspectable var starCount:Int = 5{
        didSet{
            setupButtons()
        }
    }
    
    private var ratingButtons:[UIButton] = [UIButton]()
    var rating:Int = 0{
        didSet{
            updateButtonSelectionStates()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    
    //MARK: Private Methods
    private func setupButtons(){
        // clear any existing buttons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let bundle:Bundle = Bundle(for: type(of: self))
        let filledStar:UIImage? = UIImage(named:"highlightedStar", in:bundle, compatibleWith:self.traitCollection)
        let emptyStar:UIImage? = UIImage(named:"emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar:UIImage? = UIImage(named: "filledStar", in:bundle, compatibleWith:self.traitCollection)
        
        for _ in 0..<starCount{
            let button = UIButton()
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted,.selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            //Add the button to the stack
            addArrangedSubview(button)
            
            //add new button to the rating button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionStates()
    }
    
    
    //MARK: Button Action
    @objc func ratingButtonTapped(button:UIButton){
        guard let index = ratingButtons.index(of: button) else{
            fatalError("The button,\(button), is not in the ratingButtons aray:\(ratingButtons)")
        }
        
        let selectedRating:Int = index + 1
        
        if selectedRating == rating{
            // If the selected star represents the current rating, reset the rating to 0.
            rating = 0
            updateFirebase(rating:rating)
        }else{
            // Otherwise set the rating to the selected star
            rating = selectedRating
            updateFirebase(rating:rating)
        }
    }
    
    private func updateButtonSelectionStates(){
        for (index,button) in ratingButtons.enumerated(){
            //if the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
        }
    }
    
    func updateFirebase(rating:Int){
        print("rating \(rating)")
        if let delegate = delegate{
            print("rating \(rating)")
            delegate.ratingPicker(self, didPick: rating)
        }
        print("rating \(rating)")
    }
}
