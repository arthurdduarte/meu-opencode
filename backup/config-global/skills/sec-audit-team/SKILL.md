---
name: sec-audit-team
description: >
  Use quando o usuario pedir para auditar a seguranca de um servidor, site,
  aplicacao web ou infraestrutura. Focada em identificar vulnerabilidades,
  expor riscos de exposicao (IPv6, CGNAT), recomendar correcoes e aplica-las
  com seguranca. Orquestra time de subagentes especializados em pentest.
  NAO usar para ataques offensivos sem autorizacao ou fora de escopo.
---

# Sec-Audit-Team

Time de subagentes especializados em auditoria de seguranca para infraestrutura
exposta na internet. Foco pratico em ambientes reais como servidores caseiros,
SBCs (OrangePi, Raspberry Pi), sites pessoais e servicos auto-hospedados.

## Filosofia

Esta skill foi projetada para:

- **Auditar sem danificar**: todas as fases sao read-only por padrao
- **Descobrir para proteger**: mapeia a superficie de ataque real
- **Corrigir com seguranca**: toda remediacao faz backup e requer aprovacao
- **Respeitar o hardware**: nenhum teste de stress, DoS, ou acao destrutiva

## Quando usar

Ative esta skill quando o usuario pedir para:
- "Auditar a seguranca do meu servidor"
- "Testar vulnerabilidades do meu site/servico"
- "Verificar exposicao na internet / IPv6 / CGNAT"
- "Fazer um pentest no meu OrangePi / servidor caseiro"
- "Quero saber se meu servico esta seguro"

## Subagentes disponiveis

| Subagente | Responsabilidade |
|-----------|-----------------|
| `sec-execution-manager` | Orquestra pipeline, valida escopo, gerencia fluxo entre fases, controla kill switch |
| `sec-recon-dns` | Reconhecimento: DNS, subdominios, certificados, OSINT, Shodan, whosi |
| `sec-scanner` | Varredura de portas, deteccao de versoes, identificacao de CVEs |
| `sec-webapp` | Testes em aplicacoes web: NGINX, headers HTTP, Gitea, SQLi, XSS, diretorios |
| `sec-network` | Testes de rede: IPv6 security, firewall, CGNAT bypass, acesso remoto |
| `sec-reporter` | Documentacao: relatorio final, classificacao de risco, remediacao |

## Pipeline completo

```
FASE 1 - SETUP E VALIDACAO (Execution Manager)
  ├── Verifica se o container Kali esta disponivel
  ├── Descobre IP/local do alvo na rede
  ├── Valida conectividade com o alvo
  └── Confirma escopo com o usuario

FASE 2 - RECONHECIMENTO (Recon DNS)
  ├── DNS: A/AAAA/MX/TXT/CNAME do dominio alvo
  ├── Certificado SSL/TLS (cadeia, validade, algoritmo)
  ├── Whois do dominio
  ├── Shodan/Censys: exposicao publica conhecida
  └── Subdominios via DNS brute-force

FASE 3 - VARREDURA (Scanner)
  ├── nmap stealth (-sS -sV -T2) nas portas comuns
  ├── nmap full port scan (1-65535 UDP/TCP)
  ├── Deteccao de sistema operacional
  ├── Scripts NSE de seguranca (safe category)
  └── Correlacao com banco de CVEs

FASE 4 - TESTES WEB (WebApp)
  ├── whatweb: fingerprint de tecnologias
  ├── nikto: scans de vulnerabilidades web
  ├── gobuster: enumeracao de diretorios/arquivos
  ├── NGINX: headers de seguranca (HSTS, CSP, X-Frame-Options, etc.)
  ├── Gitea: versao, autenticacao, permissoes, API
  ├── SQLi / XSS / LFI (payloads nao destrutivos)
  └── Analise de formularios e parametros

FASE 5 - REDE (Network)
  ├── IPv6: scan de enderecos link-local e globais
  ├── Firewall: rules inbound/outbound detectaveis
  ├── CGNAT: mapeamento do que realmente esta exposto
  ├── SSH: versao e configuracao de autenticacao
  └── servicos internos vs servicos publicos via dyndns

FASE 6 - RELATORIO E REMEDIACAO (Reporter)
  ├── Compila achados de todas as fases
  ├── Classifica por severidade (CRITICAL / HIGH / MEDIUM / LOW / INFO)
  ├── Para cada achado: descricao + impacto + prova + correcao
  ├── Oferece remediacao automatica (com backup + aprovacao)
  └── Relatorio final markdown no workspace
```

## Regras de seguranca (blindagens obrigatorias)

1. **READ-ONLY FIRST** — Recon e scan sao sempre passivos. Qualquer alteracao no alvo exige aprovacao explicita do usuario
2. **SEM DOS** — Todos os scans usam rate limiting (nmap `-T2` no maximo, pausas de 100ms+ entre requests web). Sem fuzz pesado
3. **SEM DANO AO HARDWARE** — Nada de CPU/mem stress, firmware, boot, flash, ou escrita no disco do alvo
4. **SEM PERSISTENCIA** — Testes de exploracao sao prova-de-conceito apenas. Nenhum payload persistente, backdoor, ou alteracao de configuracao de producao sem backup e aprovacao
5. **BACKUP ANTES DE CORRIGIR** — Qualquer remediacao que altere arquivos no alvo faz backup do original com timestamp
6. **KILL SWITCH** — O usuario pode abortar QUALQUER fase a qualquer momento dizendo "pare", "stop", "cancela", ou "aborta"
7. **3 STRIKES** — Se uma task falhar 3 vezes no mesmo ponto, o pipeline para com relatorio de erro sem continuar
8. **ESCOPO FIXO** — Nunca ataque fora do escopo definido na Fase 1. Se descobrir algo fora, reporte mas nao teste

## Fluxo do Execution Manager

```
recebeu escopo do usuario?
  ├── SIM:
  │     ├── Container Kali pronto?
  │     │     ├── SIM → Iniciar pipeline
  │     │     └── NAO → Buildar container ou orientar usuario
  │     └── Alvo alcancavel?
  │           ├── SIM → Proximo fase
  │           └── NAO → Ajudar usuario a configurar rede
  └── NAO:
        └── Perguntar escopo (dominio/IP/servicos)
```

A cada transicao de fase:
1. Mensagem de status para o usuario
2. Executa subagente via `task`
3. Coleta resultado
4. Decide proximo passo
5. Se kill switch acionado → para e gera relatorio parcial

## Fluxo de feedback entre agentes

```
Execution Manager
      │
      ├──► Recon DNS ──► Scanner ──► WebApp ──► Network
      │                                              │
      │                                              ▼
      └──────────────────────────────────────► Reporter ──► Usuario
                                                     │
                                                     ▼
                                              (remediacao com aprovacao)
```

As fases sao sequenciais obrigatorias. Nao pule fases. Cada fase so comeca quando a anterior entrega resultado valido.

## Execucao automatica

O pipeline roda do inicio ao fim sem intervencao manual apos a Fase 1. A cada fase:

1. Dispare mensagem de status para o usuario informando qual fase esta comecando
2. Execute o subagente da fase via `task`
3. Colete o resultado e use como entrada para a fase seguinte
4. Dispare mensagem de conclusao da fase e status detalhado
5. Prossiga automaticamente para a proxima fase
6. Se o usuario disser "pare" em qualquer momento, interrompa o pipeline e gere relatorio parcial
