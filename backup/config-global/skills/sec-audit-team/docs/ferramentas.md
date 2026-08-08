# Catalogo de Ferramentas do Container Pentest

Container base: **kalilinux/kali-rolling**
Nome: `kali-pentest`

## Ferramentas instaladas

### Rede e Scan
| Ferramenta | Uso | Comando exemplo |
|-----------|-----|----------------|
| **nmap** | Port scanning, service detection, NSE scripts | `nmap -sS -sV -T2 <alvo>` |
| **netcat** | Conexao TCP/UDP, banner grab | `nc -v <alvo> <porta>` |
| **iproute2** | Configuracao de rede (ip, ss) | `ip a`, `ss -tlnp` |
| **dnsutils** | DNS queries (dig, nslookup) | `dig +short AAAA <dominio>` |
| **whois** | Consulta WHOIS | `whois <dominio>` |
| **dnsrecon** | DNS enumeration | `dnsrecon -d <dominio> -t std` |

### Web
| Ferramenta | Uso | Comando exemplo |
|-----------|-----|----------------|
| **curl** | Requisicoes HTTP | `curl -sI https://<dominio>` |
| **wget** | Download de paginas | `wget <url>` |
| **whatweb** | Fingerprint de tecnologias | `whatweb -a 1 <dominio>` |
| **nikto** | Scanner de vulns web | `nikto -h https://<dominio>` |
| **gobuster** | Enumeracao de diretorios | `gobuster dir -u <url> -w <wordlist>` |
| **wfuzz** | Fuzzing web (parametros) | `wfuzz -c -z file,<wordlist> <url>` |

### Utilitarios
| Ferramenta | Uso | Comando exemplo |
|-----------|-----|----------------|
| **openssl** | SSL/TLS, certificados | `openssl s_client -connect <host>:443` |
| **jq** | Processamento JSON | `curl <api> \| jq '.'` |
| **python3** | Scripts customizados | `python3 -c "..."` |
| **dirb** | Scanner de diretorios (wordlists) | `dirb https://<dominio>` |

## Wordlists disponiveis

- `/usr/share/wordlists/dirb/common.txt` — wordlist para gobuster/dirb (~4600 palavras)
- `/usr/share/wordlists/dnsmap.txt` — wordlist para dnsrecon

## O que NÃO esta incluido (propositalmente)

| Ferramenta | Motivo |
|-----------|--------|
| hashcat / john | Quebra de senhas (desnecessario para auditoria de infra) |
| hydra / medusa | Forca bruta (pode causar lockout / DoS) |
| hping3 | DoS / packet flooding |
| slowloris | DoS em servidores web |
| aircrack-ng | Ataques WiFi (fora de escopo) |
| metasploit-framework | Exploitation framework (pesado, 3GB+; usar sob demanda) |
