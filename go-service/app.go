package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"sync/atomic"
	"time"

	dapr "github.com/dapr/go-sdk/client"
	"github.com/gorilla/mux"
)

type App struct {
	Router      *mux.Router
	daprClient  dapr.Client
	initialized atomic.Bool
}

func (a *App) Initialize(client dapr.Client) {
	a.daprClient = client
	a.Router = mux.NewRouter()

	a.Router.HandleFunc("/", a.Hello).Methods("GET")
	a.Router.HandleFunc("/inventory", a.GetInventory).Methods("GET")
	a.Router.HandleFunc("/health/live", a.Live).Methods("GET")
	a.Router.HandleFunc("/health/ready", a.Ready).Methods("GET")
	a.Router.HandleFunc("/health/startup", a.Startup).Methods("GET")

	go a.backgroundInit()
}

func (a *App) Hello(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello world! It's me"))
}

func (a *App) GetInventory(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Inventory in stock"))
}

func (a *App) Live(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func (a *App) Ready(w http.ResponseWriter, r *http.Request) {
	if a.initialized.Load() {
		w.WriteHeader(http.StatusOK)
	} else {
		w.WriteHeader(http.StatusServiceUnavailable)
	}
}

func (a *App) Startup(w http.ResponseWriter, r *http.Request) {
	if a.initialized.Load() {
		w.WriteHeader(http.StatusOK)
	} else {
		w.WriteHeader(http.StatusServiceUnavailable)
	}
}

func (a *App) backgroundInit() {
	// Attempt to ensure Dapr sidecar is responsive before marking ready
	attempts := 0
	for attempts < 30 {
		daprPort := os.Getenv("DAPR_HTTP_PORT")
		if daprPort == "" {
			daprPort = "3500"
		}
		url := fmt.Sprintf("http://localhost:%s/v1.0/healthz", daprPort)
		resp, err := http.Get(url)
		if err == nil {
			if resp != nil {
				resp.Body.Close()
			}
			if resp != nil && resp.StatusCode == http.StatusOK {
				a.initialized.Store(true)
				return
			}
		}
		attempts++
		time.Sleep(2 * time.Second)
	}
}

func (a *App) Run(addr string) {
	log.Fatal(http.ListenAndServe(addr, a.Router))
}
