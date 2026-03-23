using System.Security.Cryptography;

var options = ParseArgs(args);
var locale = PickLocale(options.Locale);

if (options.FileType is not ("bat" or "exe"))
{
    Console.WriteLine(locale.Unsupported);
    return;
}

if (!options.Url.StartsWith("http://") && !options.Url.StartsWith("https://"))
{
    Console.WriteLine(locale.InvalidUrl);
    return;
}

Console.WriteLine(locale.Downloading);
using var client = new HttpClient();
var payload = await client.GetByteArrayAsync(options.Url);
await File.WriteAllBytesAsync(options.Out, payload);

var hash = Convert.ToHexString(SHA256.HashData(payload)).ToLowerInvariant();
Console.WriteLine($"{locale.Saved}: {options.Out}");
Console.WriteLine($"SHA256: {hash}");

static Options ParseArgs(string[] args)
{
    var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    for (int i = 0; i < args.Length - 1; i += 2)
    {
        dict[args[i].TrimStart('-')] = args[i + 1];
    }

    return new Options(
        dict.GetValueOrDefault("url", string.Empty),
        dict.GetValueOrDefault("out", "godrop-output.bat"),
        dict.GetValueOrDefault("type", "bat").ToLowerInvariant(),
        dict.GetValueOrDefault("locale", "en").ToLowerInvariant()
    );
}

static Locale PickLocale(string code) => code switch
{
    "es" => new("Descargando artefacto...", "Guardado", "Solo se admiten archivos .exe y .bat.", "La URL debe usar http o https."),
    "fr" => new("Téléchargement de l'artefact...", "Enregistré", "Seuls les fichiers .exe et .bat sont pris en charge.", "L'URL doit utiliser http ou https."),
    _ => new("Downloading artifact...", "Saved", "Only .exe and .bat files are supported.", "URL must use http or https.")
};

record Options(string Url, string Out, string FileType, string Locale);
record Locale(string Downloading, string Saved, string Unsupported, string InvalidUrl);
