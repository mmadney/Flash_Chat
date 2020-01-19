import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UITextFieldDelegate {

    var messageArray : [Message] = [Message]()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        messageTableView.dataSource = self
        messageTableView.delegate = self


        messageTextfield.delegate = self
        

        let tabgesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tabgesture)

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil),  forCellReuseIdentifier: "customMessageCell")

        configureTableView()
        retrivesMessages()
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
    
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")

        if cell.senderUsername.text == FIRAuth.auth()?.currentUser?.email {
           cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else
        {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatBlue()
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    

    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 383
            self.view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
        }
        
    }

    @IBAction func sendPressed(_ sender: AnyObject) {

        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDatabase = FIRDatabase.database().reference().child("Message")
        let messageDic = ["sender":FIRAuth.auth()?.currentUser?.email,"messageBody":messageTextfield.text!]
        messageDatabase.childByAutoId().setValue(messageDic){
            (error , ref) in
            if error != nil {
                print(error!)
            }
            else{
                print("Message Send it Sucessfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        
        
    }
    
    func retrivesMessages()
    {
        let messageDatabase = FIRDatabase.database().reference().child("Message")
        
        messageDatabase.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["messageBody"]!
            let sender = snapshotValue["sender"]!
           let message = Message()
            message.messageBody = text
            message.sender = sender
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
        
    }

    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch  {
            print("error while signing out")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil else {
            print("no view controllers pop off")
            return
        }
    }
    


}
