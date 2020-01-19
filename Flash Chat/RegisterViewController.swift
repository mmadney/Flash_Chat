import UIKit
import Firebase
import SVProgressHUD
class RegisterViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        SVProgressHUD.show()
        FIRAuth.auth()?.createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!, completion: { (user, err) in
            if err != nil
            {
                print(err!)
            }
            else
            {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToChat", sender: nil)
            }
        })
        
    } 
    
    
}
