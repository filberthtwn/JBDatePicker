//
//  CodedDatePickerViewController.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 08-12-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit


class CodedDatePickerViewController: UIViewController, JBDatePickerViewDelegate {
    
    var datePicker: JBDatePickerView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    lazy var dateFormatter: DateFormatter = {
        
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = JBDatePickerView()
        view.addSubview(datePicker)
        datePicker.delegate = self
        
        //update dayLabel
        dayLabel.text = dateFormatter.string(from: Date())
        
        //add constraints
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.heightAnchor.constraint(equalToConstant: 250).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        if #available(iOS 11.0, *) {
            datePicker.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            datePicker.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            let topguideBottom = self.topLayoutGuide.bottomAnchor
            datePicker.topAnchor.constraint(equalTo: topguideBottom).isActive = true
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - JBDatePickerViewDelegate
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        
       dayLabel.text = dateFormatter.string(from: dayView.date!)
    }
    
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
       monthLabel.text = monthView.monthDescription 
        
    }
    
    //custom first day of week
    var firstWeekDay: JBWeekDay {
        return .wednesday
    }
    
    //custom font for weekdaysView
    var fontForWeekDaysViewText: JBFont {

        return JBFont(name: "AvenirNext-MediumItalic", size: .medium)
    }
    
    //custom font for dayLabel
    var fontForDayLabel: JBFont {
        return JBFont(name: "Avenir", size: .medium)
    }
    
    //custom colors
    var colorForWeekDaysViewBackground: UIColor {
        return UIColor(red: 209.0/255.0, green: 218.0/255.0, blue: 175.0/255.0, alpha: 1.0)
    }
    
    var colorForSelectionCircleForOtherDate: UIColor {
        return UIColor(red: 209.0/255.0, green: 218.0/255.0, blue: 175.0/255.0, alpha: 1.0)
    }
    
    var colorForSelectionCircleForToday: UIColor {
        return UIColor(red: 191.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
    }
    
    //only show the dates of the current month
    var shouldShowMonthOutDates: Bool {
        return false 
    }
    
    //custom weekdays view height
    var weekDaysViewHeightRatio: CGFloat {
        return 0.15
    }
    
    //custom selection shape
    var selectionShape: JBSelectionShape {
        return .fullBackground
    }
    
    public var colorForDayLabelInMonth: UIColor { return .darkGray }
    public var colorForDayLabelInMonthBackground: UIColor { return .lightGray }
    public var colorForDayLabelOutOfMonth: UIColor { return .lightGray }
    public var colorForDayLabelOutOfMonthBackground: UIColor { return .yellow }
    public var colorForUnavailableDay: UIColor { return .lightGray }
    public var colorForUnavailableDayBackground: UIColor { return .green }

    func shouldAllowSelectionOfDay(_ date: Date?) -> Bool {
        
        //this code example disables selection for dates older then today
        guard let date = date else {return true}
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)
        
        if weekday == 6 || weekday == 7 {
            return false
        }
        return true
    }
    
    func colorForSpecificDate(_ date: Date?) -> UIColor? {
        guard let date = date else {return nil}
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)
        
        if weekday == 6 {
            return UIColor.blue
        }
        return nil
    }
    
    func colorForSpecificDateBackground(_ date: Date?) -> UIColor? {
        guard let date = date else {return nil}
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)
        
        if weekday == 6 {
            return UIColor.purple
        }
        return nil
    }
}
