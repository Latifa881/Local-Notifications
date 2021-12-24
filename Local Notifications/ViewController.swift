//
//  ViewController.swift
//  Local Notifications
//
//  Created by administrator on 14/12/2021.
//

import UIKit


class ViewController: UIViewController {
    
    let timeArr:[Int] = [5,10,20,30]
    
    var runningNotifications: [LocalNotification] = []

    
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var timerSetLabel: UILabel!
    @IBOutlet weak var workUntilLabel: UILabel!
    
    @IBOutlet weak var startTimerButton: UIButton!
    
    var selectedTime: Int = 5
    var hours: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        startTimerButton.layer.cornerRadius = 10
        startTimerButton.clipsToBounds = true
    }
    
    //
    
    func createLocalNotification(time: Int) -> String{
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Timer is done!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "You studied \(time) minutes good job!", arguments: nil)
        content.sound = UNNotificationSound.default
        
        
        let currentDate = Date(timeIntervalSinceNow: Double(time))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        let currentTime = formatter.string(from: currentDate)
        
        
        let localNotification = LocalNotification(isActive: true, length: time, dateItEnds: currentDate)
        runningNotifications.append(localNotification)
        
        
        
        let dateComponent = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: currentDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "TimerAlarm", content: content, trigger: trigger)
        
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
            
        }
        
        
        return currentTime
        
        
    }
    

    @IBAction func startTimerPressed(_ sender: UIButton) {
        
        let currentTime = createLocalNotification(time: selectedTime*60)
        showAlert(title: "\(selectedTime)min countdown", message: "After \(selectedTime) minutes, you'll be notified")
        
        totalTimeLabel.text = "Total time: \(selectedTime)"
      
        workUntilLabel.text = "Work until \(currentTime)"
        timerSetLabel.text = "\(selectedTime) minute timer set"
        timerSetLabel.font = .boldSystemFont(ofSize: 28)
        timerSetLabel.textColor = .yellow
        
        
        
        
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        timerSetLabel.textColor = .systemGray
        timerSetLabel.font = .preferredFont(forTextStyle: .title2)
        timerSetLabel.text = "\(selectedTime) minute timer cancelled"
    }
    
    @IBAction func listButtonPressed(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        
        vc.modalPresentationStyle = .formSheet
        vc.allNotifications = runningNotifications
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
   
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(timeArr[row]) Minutes"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected minutes \(timeArr[row])")
        selectedTime = timeArr[row]
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: "\(timeArr[row]) Minutes", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemTeal])
    }
    
    
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // notification arrived
        showAlert(title: "Timer is done!", message: "You studied \(selectedTime) minutes good job!")
        timerSetLabel.textColor = .systemGray
        timerSetLabel.font = .preferredFont(forTextStyle: .title2)
        timerSetLabel.text = "\(selectedTime) minute timer done"
        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // notification clicked or opened
        print("did receive notification")
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
}


