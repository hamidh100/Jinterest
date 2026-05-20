package exceptions;

public class InvalidUsername extends Exception {
    public InvalidUsername(){
        super("Username must be a valid email or phone number");
    }
}
