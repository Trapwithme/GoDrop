use clap::Parser;
use reqwest::blocking::get;
use sha2::{Digest, Sha256};
use std::fs::File;
use std::io::Write;

#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    #[arg(long)]
    url: String,
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

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();
    let file_type = args.file_type.to_lowercase();

    if file_type != "bat" && file_type != "exe" {
        return Err("Only .exe and .bat are supported".into());
    }

    println!("{}", message(&args.locale, "downloading"));
    let bytes = get(&args.url)?.bytes()?;

    let mut file = File::create(&args.out)?;
    file.write_all(&bytes)?;

    let mut hasher = Sha256::new();
    hasher.update(&bytes);
    let hash = hasher.finalize();

    println!("{}: {}", message(&args.locale, "saved"), args.out);
    println!("SHA256: {:x}", hash);
    Ok(())
}
