package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	defaultPort := "8080"
	listenPort, ok := os.LookupEnv("PORT")
	if !ok {
		listenPort = defaultPort
	}

	http.HandleFunc("/", hello)

	http.ListenAndServe("0.0.0.0:"+listenPort, nil)
}

func hello(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "hello\n")
}
