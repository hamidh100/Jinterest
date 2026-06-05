package exceptions;

public class InvalidLoginMethod extends Exception {
    public InvalidLoginMethod(){
        super("You must login with a valid email, phone number or username");
    }
}

