package main

import (
    "crypto/sha256"
    "encoding/hex"
    "errors"
    "flag"
    "fmt"
    "io"
    "net/http"
    "os"
    "path/filepath"
    "strings"
)

type localeMessages struct {
    downloading string
    saved       string
    hash        string
    unsupported string
    invalidURL  string
}

var locales = map[string]localeMessages{
    "en": {
        downloading: "Downloading artifact...",
        saved:       "Saved",
        hash:        "SHA256",
        unsupported: "Only .exe and .bat files are supported.",
        invalidURL:  "URL must use http or https.",
    },
    "es": {
        downloading: "Descargando artefacto...",
        saved:       "Guardado",
        hash:        "SHA256",
        unsupported: "Solo se admiten archivos .exe y .bat.",
        invalidURL:  "La URL debe usar http o https.",
    },
    "fr": {
        downloading: "Téléchargement de l'artefact...",
        saved:       "Enregistré",
        hash:        "SHA256",
        unsupported: "Seuls les fichiers .exe et .bat sont pris en charge.",
        invalidURL:  "L'URL doit utiliser http ou https.",
    },
}

func pickLocale(code string) localeMessages {
    if l, ok := locales[strings.ToLower(code)]; ok {
        return l
    }
    return locales["en"]
}

func validateType(t string) error {
    switch strings.ToLower(t) {
    case "exe", "bat":
        return nil
    default:
        return errors.New("unsupported file type")
    }
}

func download(url, outputPath string) (string, error) {
    resp, err := http.Get(url)
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    if resp.StatusCode < 200 || resp.StatusCode >= 300 {
        return "", fmt.Errorf("unexpected status: %s", resp.Status)
    }

    out, err := os.Create(outputPath)
    if err != nil {
        return "", err
    }
    defer out.Close()

    hasher := sha256.New()
    writer := io.MultiWriter(out, hasher)

    if _, err = io.Copy(writer, resp.Body); err != nil {
        return "", err
    }

    return hex.EncodeToString(hasher.Sum(nil)), nil
}

func main() {
    url := flag.String("url", "", "Source URL")
    out := flag.String("out", "", "Destination file path")
    fileType := flag.String("type", "bat", "Artifact type: bat or exe")
    locale := flag.String("locale", "en", "Locale: en, es, fr")
    flag.Parse()

    msg := pickLocale(*locale)

    if err := validateType(*fileType); err != nil {
        fmt.Println(msg.unsupported)
        os.Exit(1)
    }

    if !strings.HasPrefix(*url, "https://") && !strings.HasPrefix(*url, "http://") {
        fmt.Println(msg.invalidURL)
        os.Exit(1)
    }

    if *out == "" {
        *out = filepath.Join(os.TempDir(), "godrop-output."+strings.ToLower(*fileType))
    }

    fmt.Println(msg.downloading)
    sum, err := download(*url, *out)
    if err != nil {
        fmt.Printf("error: %v\n", err)
        os.Exit(1)
    }

    fmt.Printf("%s: %s\n", msg.saved, *out)
    fmt.Printf("%s: %s\n", msg.hash, sum)
}
