#include <array>
#include <fstream>
#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cout << "Usage: godrop_cpp <url> <out> [bat|exe] [locale]" << std::endl;
        return 1;
    }

    std::string url = argv[1];
    std::string out = argv[2];
    std::string type = argc > 3 ? argv[3] : "bat";
    std::string locale = argc > 4 ? argv[4] : "en";

    if (type != "bat" && type != "exe") {
        std::cerr << "Only bat and exe are supported." << std::endl;
        return 1;
    }

    std::string downloading = "Downloading artifact with curl...";
    std::string saved = "Saved";

    if (locale == "es") {
        downloading = "Descargando artefacto con curl...";
        saved = "Guardado";
    } else if (locale == "fr") {
        downloading = "Téléchargement de l'artefact avec curl...";
        saved = "Enregistré";
    }

    std::cout << downloading << std::endl;
    std::string cmd = "curl -L \"" + url + "\" -o \"" + out + "\"";
    int rc = std::system(cmd.c_str());
    if (rc != 0) {
        std::cerr << "Download failed." << std::endl;
        return rc;
    }

    std::cout << saved << ": " << out << std::endl;
    std::cout << "Use platform tools to inspect SHA256 (e.g., certutil/Get-FileHash)." << std::endl;
    return 0;
}
