public class User {
    private String username, password, fullname;
    public User(String username, String password){
        this.username = username;
        this.password = password;
    }
    public User(String username, String password, String fullname){
        this.username = username;
        this.password = password;
        this.fullname = fullname;
    }

    /* getter setter begin */
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getFullname() {
        return fullname;
    }
    public void setFullname(String fullname) {
        this.fullname = fullname;
    }
    /* getter setter end */
}
