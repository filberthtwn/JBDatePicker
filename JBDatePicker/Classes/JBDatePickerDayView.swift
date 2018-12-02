//
//  JBDatePickerDayView.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 13-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

public final class JBDatePickerDayView: UIView {

    // MARK: - Properties
    private var index: Int!
    private var dayInfo: JBDay!
    weak private var weekView: JBDatePickerWeekView!
    weak private var monthView: JBDatePickerMonthView!
    weak var datePickerView: JBDatePickerView!
    public var date: Date?

    var isToday: Bool {
        return date == Date().stripped()
    }
    
    private var textLabel: UILabel!
    private weak var selectionView: JBDatePickerSelectionView?
    
    private let longPressArea: CGFloat = 40
    private var longPressAreaMaxX: CGFloat { return bounds.width + longPressArea }
    private var longPressAreaMaxY: CGFloat { return bounds.height + longPressArea }
    private var longPressAreaMin: CGFloat { return -longPressArea }
    
    private var backgroundView:UIView!
    
    
    // MARK: - Initialization
    
    init(datePickerView: JBDatePickerView, monthView: JBDatePickerMonthView, weekView: JBDatePickerWeekView, index: Int, dayInfo: JBDay) {
        
        self.datePickerView = datePickerView
        self.monthView = monthView
        self.weekView = weekView
        self.index = index
        self.dayInfo = dayInfo
        
        if let size = datePickerView.dayViewSize {
            
            let frame = CGRect(x: size.width * CGFloat(index), y: 0, width: size.width, height: size.height)
            super.init(frame: frame)

        }
        else{
            super.init(frame: .zero)
        }
        
        //backgroundColor = randomColor()
        self.date = dayInfo.date
        labelSetup()
        backgroundViewSetup()
    
        if dayInfo.isInMonth {
            
            //set default color
            textLabel.textColor = datePickerView.delegate?.colorForDayLabelInMonth
            backgroundView.backgroundColor = datePickerView.delegate?.colorForDayLabelInMonthBackground
            
            if let color = datePickerView.colorForSpecificDate(date: date) {
                self.textLabel.textColor = color
            }
            
            if let backgroundColor = datePickerView.colorForSpecificDateBackground(date: date) {
                self.backgroundView.backgroundColor = backgroundColor
            }
            
            //check date is selectable, if not selectable, set colour and don't add gestures
            guard datePickerView.dateIsSelectable(date: date) else {
                if datePickerView.colorForSpecificDate(date: date) == nil {
                    self.textLabel.textColor = datePickerView.delegate?.colorForUnavailableDay
                }
                if datePickerView.colorForSpecificDateBackground(date: date) == nil {
                    self.backgroundView.backgroundColor = datePickerView.delegate?.colorForUnavailableDayBackground
                }
                return
            }

        }
        else{
            
            if let shouldShow = datePickerView.delegate?.shouldShowMonthOutDates {
                if shouldShow {
                    textLabel.textColor = datePickerView.delegate?.colorForDayLabelOutOfMonth
                    backgroundView.backgroundColor = datePickerView.delegate?.colorForDayLabelInMonthBackground
                    
                    //check date is selectable, if not selectable, don't add gestures
                    guard datePickerView.dateIsSelectable(date: date) else {return}
                }
                else{
                    self.isUserInteractionEnabled = false
                    self.textLabel.isHidden = true
                }
            }
        }

        
        //highlight current day. Must come before selection of selected date, because it would override the text color set by select()
        if isToday {
            self.textLabel.textColor = datePickerView.delegate?.colorForCurrentDay
        }
        
        //select selected day
        if date == datePickerView.dateToPresent.stripped() {
            guard self.dayInfo.isInMonth else { return }
            datePickerView.selectedDateView = self
            //self.backgroundColor = randomColor()
        }

        //add tapgesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dayViewTapped))
        self.addGestureRecognizer(tapGesture)
        
        //add longPress gesture recognizer
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(dayViewPressed(_:)))
        self.addGestureRecognizer(pressGesture)

    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Label setup
    
    private func labelSetup() {
        
        textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false 
        self.addSubview(textLabel)
        
        textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }
    
    private func backgroundViewSetup(){
        backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        self.insertSubview(backgroundView, at: 0)
        
        backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1).isActive = true
        
    }
    
    private func setupLabelFont() {
        
        //get preferred font
        guard let preferredFont = datePickerView.delegate?.fontForDayLabel else { return }
        
        //get preferred size
        let preferredSize = preferredFont.fontSize
        let sizeOfFont: CGFloat
        
        //calculate fontsize to be used
        switch preferredSize {
        case .verySmall: sizeOfFont = min(frame.size.width, frame.size.height) / 3.5
        case .small: sizeOfFont = min(frame.size.width, frame.size.height) / 3
        case .medium: sizeOfFont = min(frame.size.width, frame.size.height) / 2.5
        case .large: sizeOfFont = min(frame.size.width, frame.size.height) / 2
        case .veryLarge: sizeOfFont = min(frame.size.width, frame.size.height) / 1.5
        }
        
        //get font to be used
        let fontToUse: UIFont
        switch preferredFont.fontName.isEmpty {
        case true:
            fontToUse = UIFont.systemFont(ofSize: sizeOfFont, weight: UIFont.Weight.regular)
        case false:
            if let customFont = UIFont(name: preferredFont.fontName, size: sizeOfFont) {
                fontToUse = customFont
            }
            else {
                print("custom font '\(preferredFont.fontName)' for dayLabel not available. JBDatePicker will use system font instead")
                fontToUse = UIFont.systemFont(ofSize: sizeOfFont, weight: UIFont.Weight.regular)
            }
        }
        
        textLabel.attributedText = NSMutableAttributedString(string: String(dayInfo.dayValue), attributes:[NSAttributedStringKey.font: fontToUse])
        
    }
    
    public override func layoutSubviews() {
        
        textLabel.frame = bounds
        setupLabelFont()
    }
    
    
    // MARK: - Touch handling
    
    @objc public func dayViewTapped() {
        datePickerView.didTapDayView(dayView: self)
    }
    
    @objc public func dayViewPressed(_ gesture: UILongPressGestureRecognizer) {
        
        //if selectedDateView exists and is self, return. Long pressing shouldn't do anything on selected day. 
        if let selectedDate = datePickerView.selectedDateView {
            guard selectedDate != self else { return }
        }
        
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            semiSelect(animated: true)
        case .ended:
            if let selView = selectionView {
                selView.removeFromSuperview()
            }
            datePickerView.didTapDayView(dayView: self)
        
        case .changed:
            
            if !(longPressAreaMin...longPressAreaMaxX).contains(location.x) || !(longPressAreaMin...longPressAreaMaxY).contains(location.y) {
 
                semiDeselect(animated: true)
                
                //this will cancel the longpress gesture (and enable it again for the next time)
                gesture.isEnabled = false
                gesture.isEnabled = true
            }

        default:
            break
        }
    }
    
    // MARK: - Reloading
    
    public func reloadContent() {
        textLabel.frame = bounds
        setupLabelFont()
        
        //reload selectionView
        if let selView = selectionView {

            selView.frame = textLabel.frame
            selView.setNeedsDisplay()
        }

    }
    
    
    // MARK: - Selection & Deselection
    
    func select() {

        let selView = JBDatePickerSelectionView(dayView: self, frame: self.bounds, isSemiSelected: false)
        insertSubview(selView, aboveSubview: backgroundView)

        selView.translatesAutoresizingMaskIntoConstraints = false
        
        //pin selectionView horizontally and make it's width equal to the height of the datePickerview. This way it stays centered while rotating the device.
        selView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        selView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        selView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        selectionView = selView
        
        //set textcolor to selected state
        textLabel.textColor = datePickerView.delegate?.colorForSelectedDayLabel
    }
    
    func deselect() {

        if let selectionView = selectionView {
            selectionView.removeFromSuperview()
        }
        
        //set textcolor to default color
        if isToday {
            textLabel.textColor = datePickerView.delegate?.colorForCurrentDay
        } else if dayInfo.isInMonth {
            textLabel.textColor = datePickerView.delegate?.colorForDayLabelInMonth
            if let color = datePickerView.colorForSpecificDate(date: date) {
                 textLabel.textColor = color
            }
        } else {
            textLabel.textColor = datePickerView.delegate?.colorForDayLabelOutOfMonth
        }
    }
    
    /**
     creates and shows a selection circle with a semi selected color
     
     - Parameter animated: if true, this will fade in the circle
     
     */
    private func semiSelect(animated: Bool) {
        
        if let selectionView = selectionView {
            if animated {
                insertCircleViewAnimated(selectionView: selectionView)
            }
            else{
                insertSubview(selectionView, at: 0)
            }
        }
        else {
            let selView = JBDatePickerSelectionView(dayView: self, frame: self.bounds, isSemiSelected: true)
                if animated {
                    insertCircleViewAnimated(selectionView: selView)
                }
                else{
                    insertSubview(selView, at: 0)
                }
            selectionView = selView
        }
    }
    
    /**
     removes semi selected selection circle and removes circle from superview
     
     - Parameter animated: if true, this will fade the circle out before removal
     
     */
    private func semiDeselect(animated: Bool) {
        
        switch animated {
        case true:
            removeCircleViewAnimated()
        case false:
            selectionView?.removeFromSuperview()
        }
    }
    
    ///just a helper that inserts the selection circle animated
    private func insertCircleViewAnimated(selectionView: JBDatePickerSelectionView) {
        
        selectionView.alpha = 0.0
        insertSubview(selectionView, at: 0)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            selectionView.alpha = 1.0
        
        })
    }
    
    ///just a helper that removes the selection circle animated
    private func removeCircleViewAnimated() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.selectionView?.alpha = 0.0
            
            }, completion: {_ in
                self.selectionView?.removeFromSuperview()
        })
    }
    

}
