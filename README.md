# **CPU Mitigations Disabler Tool**

## ⚠️ **Aviso de Segurança Crítico**

**Este software desativa proteções de segurança do processador. Isso torna seu sistema vulnerável a explorações como Spectre, Meltdown, MDS, ZombieLoad e outros ataques side-channel. Use por sua própria conta e risco!**

### ❌ **NUNCA USE EM:**
- Sistemas de produção
- Máquinas com dados sensíveis
- Computadores conectados à internet
- Servidores acessíveis publicamente
- Qualquer ambiente onde segurança seja importante

### ✅ **USE APENAS EM:**
- Laboratórios isolados de rede
- Benchmarks temporários
- Máquinas de teste descartáveis
- Ambientes de pesquisa controlados

## 📋 **Descrição**

Ferramenta Bash para desativar mitigações de segurança do processador em sistemas Linux baseados em Ubuntu/Debian, visando aumento de desempenho em troca da redução de segurança.

## 🚀 **Funcionalidades**

- ✅ Desativação completa de mitigações (máximo desempenho)
- ⚙️ Configuração otimizada (equilíbrio desempenho/segurança)
- 🔄 Restauração automática de configurações
- 💾 Sistema de backup integrado
- 📊 Verificação de estado atual
- ⏱️ Benchmark rápido integrado
- 🛡️ Múltiplos avisos de segurança
- 🔧 Suporte a BIOS e UEFI

## 📊 **Ganhos de Desempenho Esperados**

| Carga de Trabalho | Ganho Estimado | Risco de Segurança |
|------------------|----------------|-------------------|
| Benchmarks CPU | 5-15% | ⚠️⚠️⚠️ ALTO |
| Jogos | 2-8% | ⚠️⚠️⚠️ ALTO |
| Compilação | 3-10% | ⚠️⚠️⚠️ ALTO |
| Servidores DB | 4-12% | ⚠️⚠️⚠️ ALTO |
| Virtualização | 5-20% | ⚠️⚠️⚠️ ALTO |

## 🛠️ **Instalação**

### Pré-requisitos
```bash
# Sistemas baseados em Ubuntu/Debian
sudo apt update
sudo apt install bc  # Para benchmarks
```

### Método 1: Clone o repositório
```bash
git clone https://github.com/seu-usuario/cpu-mitigations-disabler.git
cd cpu-mitigations-disabler
chmod +x desativar_mitigacoes.sh
```

### Método 2: Download direto
```bash
wget https://raw.githubusercontent.com/seu-usuario/cpu-mitigations-disabler/main/desativar_mitigacoes.sh
chmod +x desativar_mitigacoes.sh
```

## 🎮 **Como Usar**

### Execução básica:
```bash
sudo ./desativar_mitigacoes.sh
```

### Opções disponíveis no menu:
1. **Desativar TODAS as mitigações** - Máximo desempenho, máximo risco
2. **Configuração otimizada** - Recomendado para benchmarks
3. **Restaurar configurações padrão** - Voltar para segurança normal
4. **Verificar estado atual** - Ver mitigações ativas
5. **Sair** - Cancelar operação

### Verificação pós-alteração:
```bash
# Verificar mitigações ativas
cat /sys/devices/system/cpu/vulnerabilities/*

# Verificar parâmetros do kernel
cat /proc/cmdline
```

## 📁 **Estrutura do Projeto**

```
cpu-mitigations-disabler/
├── desativar_mitigacoes.sh     # Script principal
├── revert_mitigations.sh       # Script para reverter
├── README.md                   # Este arquivo
├── LICENSE                     # Licença do projeto
└── backup_mitigacoes/          # Backups automáticos
```

## 🔧 **Arquivos de Backup**

O script cria backups automáticos em:
- `/etc/default/grub.backup.YYYYMMDD_HHMMSS`
- `/root/backup_mitigacoes/`
  - `grub.original`
  - `vulnerabilities_before.txt`

## 📝 **Comandos Manuais (Alternativa)**

### Desativar mitigações manualmente:
```bash
# Editar GRUB
sudo nano /etc/default/grub

# Adicionar à linha GRUB_CMDLINE_LINUX_DEFAULT:
GRUB_CMDLINE_LINUX_DEFAULT="mitigations=off nospec_store_bypass_disable no_stf_barrier"

# Atualizar GRUB
sudo update-grub
sudo reboot
```

### Reverter manualmente:
```bash
sudo sed -i 's/ mitigations=off//g' /etc/default/grub
sudo sed -i 's/ nospec_store_bypass_disable//g' /etc/default/grub
sudo sed -i 's/ no_stf_barrier//g' /etc/default/grub
sudo update-grub
sudo reboot
```

## 🧪 **Testes e Benchmarks**

### Benchmark rápido incluído:
```bash
# Teste de cálculo (benchmark de CPU)
time for i in {1..10}; do
    echo "scale=5000; 4*a(1)" | bc -l -q > /dev/null
done

# Teste de syscall
time for i in {1..10000}; do
    getent passwd root > /dev/null
done
```

### Ferramentas recomendadas para benchmark:
```bash
# Instalar ferramentas de benchmark
sudo apt install sysbench stress-ng phoronix-test-suite

# Executar testes
sysbench cpu --cpu-max-prime=20000 run
stress-ng --cpu 4 --timeout 30s --metrics
```

## 🐛 **Solução de Problemas**

### Problema: Script não executa
```bash
# Dar permissão de execução
chmod +x desativar_mitigacoes.sh

# Executar como root
sudo ./desativar_mitigacoes.sh
```

### Problema: GRUB não atualiza
```bash
# Tentar métodos alternativos
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo update-grub2
```

### Problema: Sem efeito após reinício
```bash
# Verificar parâmetros efetivos
cat /proc/cmdline

# Verificar se mitigações estão ativas
cat /sys/devices/system/cpu/vulnerabilities/*
```

## ⚙️ **Configurações Específicas por Distribuição**

### Ubuntu/Debian:
```bash
# Funciona nativamente com update-grub
```

### Arch Linux/Manjaro:
```bash
# Usar grub-mkconfig
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Fedora/RHEL/CentOS:
```bash
# Usar grub2-mkconfig
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

## 📚 **Referências Técnicas**

### Mitigações afetadas:
- **Spectre V1/V2/V4** (Bounds Check Bypass, Branch Target Injection, Speculative Store Bypass)
- **Meltdown** (Rogue Data Cache Load)
- **MDS** (Microarchitectural Data Sampling)
- **TSX Asynchronous Abort**
- **L1 Terminal Fault**
- **SwapGS**

### Parâmetros do kernel utilizados:
- `mitigations=off` - Desativa todas as mitigações
- `nospectre_v1` - Desativa mitigação Spectre V1
- `nospectre_v2` - Desativa mitigação Spectre V2
- `mds=off` - Desativa mitigação MDS
- `tsx_async_abort=off` - Desativa mitigação TAA
- `l1tf=off` - Desativa mitigação L1TF

## 👥 **Contribuição**

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 **Licença**

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## ⚠️ **Isenção de Responsabilidade**

**ESTE SOFTWARE É FORNECIDO "COMO ESTÁ", SEM GARANTIA DE QUALQUER TIPO, EXPRESSA OU IMPLÍCITA, INCLUINDO MAS NÃO SE LIMITANDO A GARANTIAS DE COMERCIALIZAÇÃO, ADEQUAÇÃO A UM PROPÓSITO ESPECÍFICO E NÃO VIOLAÇÃO. EM NENHUMA CIRCUNSTÂNCIA OS AUTORES OU DETENTORES DE DIREITOS AUTORAIS SERÃO RESPONSÁVEIS POR QUALQUER RECLAMAÇÃO, DANOS OU OUTRA RESPONSABILIDADE, SEJA EM UMA AÇÃO DE CONTRATO, DELITO OU OUTRA FORMA, DECORRENTE DE, OU EM CONEXÃO COM O SOFTWARE OU O USO OU OUTRAS NEGOCIAÇÕES NO SOFTWARE.**

## 📞 **Suporte**

Para questões e suporte:
1. Abra uma Issue no GitHub
2. Consulte as FAQs na Wiki do projeto
3. Verifique se já existe uma solução nos Issues fechados

## 🌟 **Agradecimentos**

- Comunidade Linux Kernel
- Desenvolvedores de segurança que identificaram as vulnerabilidades
- Testadores e contribuidores do projeto

---
**Versão:** 1.0.0  
**Compatibilidade:** Ubuntu 18.04+, Debian 10+, derivados

**⚠️ LEMBRE-SE: SEGURANÇA É UMA ESCOLHA. FAÇA A SUA COM CONSCIÊNCIA! ⚠️**
