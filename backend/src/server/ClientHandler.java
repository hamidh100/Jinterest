package server;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.nio.charset.StandardCharsets;

public class ClientHandler implements Runnable {
    private static final Gson gson = new Gson();

    private final Socket socket;
    private final Router router;

    public ClientHandler(Socket socket, Router router) {
        this.socket = socket;
        this.router = router;
    }

    @Override
    public void run() {
        try (
            BufferedReader in = new BufferedReader(
                new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
            PrintWriter out = new PrintWriter(
                socket.getOutputStream(), true, StandardCharsets.UTF_8)
        ) {
            String line;
            while ((line = in.readLine()) != null) {
                Response response;
                try {
                    Request request = gson.fromJson(line, Request.class);
                    response = router.route(request);
                } catch (JsonSyntaxException e) {
                    response = Response.serverError("Invalid JSON: " + e.getMessage());
                }
                out.println(gson.toJson(response));
            }
        } catch (IOException e) {
            System.err.println("Client connection error: " + e.getMessage());
        } finally {
            try {
                socket.close();
            } catch (IOException ignored) {
            }
        }
    }
}
