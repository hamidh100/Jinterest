package exceptions;

public class InvalidSignupMethod extends Exception {
    public InvalidSignupMethod(){
        super("You must create account with a valid email or phone number");
    }
}

