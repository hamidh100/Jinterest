package exceptions;

public class UsernameAlreadyExists extends Exception {
    public UsernameAlreadyExists(){
        super("Username already exists");
    }
}

