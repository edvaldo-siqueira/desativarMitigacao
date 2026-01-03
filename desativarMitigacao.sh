#!/bin/bash

# Script para desativar mitigações de segurança do processador
# AVISO: Isso reduz a segurança do sistema!

# Verificar se é executado como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script precisa ser executado como root (sudo)"
    echo "Usage: sudo ./desativar_mitigacoes.sh"
    exit 1
fi

# Configurações
GRUB_FILE="/etc/default/grub"
GRUB_BACKUP="/etc/default/grub.backup.$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="/root/backup_mitigacoes"

# Função para exibir status
print_status() {
    echo -e "\n📊 $1"
}

# Função para criar backup
create_backup() {
    print_status "Criando backup das configurações atuais..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup do grub
    cp "$GRUB_FILE" "$GRUB_BACKUP"
    cp "$GRUB_FILE" "$BACKUP_DIR/grub.original"
    
    # Backup das vulnerabilidades atuais
    cat /sys/devices/system/cpu/vulnerabilities/* > "$BACKUP_DIR/vulnerabilities_before.txt" 2>/dev/null
    
    print_status "Backup criado em: $BACKUP_DIR"
    print_status "Backup do GRUB: $GRUB_BACKUP"
}

# Função para verificar mitigações atuais
check_current_mitigations() {
    print_status "Mitigações atualmente ativas:"
    echo "========================================"
    grep -r . /sys/devices/system/cpu/vulnerabilities/ 2>/dev/null || echo "Não foi possível ler vulnerabilidades"
    echo "========================================"
}

# Função para aplicar configurações
apply_mitigations_off() {
    print_status "Configurando GRUB para desativar todas as mitigações..."
    
    # Verificar se o parâmetro já existe
    if grep -q "mitigations=off" "$GRUB_FILE"; then
        print_status "As mitigações já estão desativadas no GRUB."
        return 0
    fi
    
    # Remover parâmetros de mitigação existentes
    sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)mitigations=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)mitigations=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)spectre_v2=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)spectre_v2=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)mds=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)mds=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    
    # Adicionar mitigations=off
    if grep -q 'GRUB_CMDLINE_LINUX_DEFAULT="' "$GRUB_FILE"; then
        sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 mitigations=off"/' "$GRUB_FILE"
    else
        sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=\)""/\1"mitigations=off"/' "$GRUB_FILE"
    fi
    
    # Adicionar também na linha GRUB_CMDLINE_LINUX para garantir
    if grep -q 'GRUB_CMDLINE_LINUX="' "$GRUB_FILE"; then
        sed -i 's/\(GRUB_CMDLINE_LINUX="[^"]*\)"/\1 mitigations=off"/' "$GRUB_FILE"
    else
        sed -i 's/\(GRUB_CMDLINE_LINUX=\)""/\1"mitigations=off"/' "$GRUB_FILE"
    fi
    
    print_status "GRUB configurado com 'mitigations=off'"
}

# Função para aplicar configurações otimizadas (recomendado)
apply_optimized_mitigations() {
    print_status "Configurando GRUB com mitigações otimizadas para desempenho..."
    
    # Configuração recomendada para máximo desempenho com algum equilíbrio
    MITIGATIONS_PARAMS="mitigations=off nospec_store_bypass_disable no_stf_barrier"
    
    # Limpar parâmetros antigos
    sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)mitigations=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)mitigations=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
    
    # Adicionar novos parâmetros
    if grep -q 'GRUB_CMDLINE_LINUX_DEFAULT="' "$GRUB_FILE"; then
        sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\)\"/\1 $MITIGATIONS_PARAMS\"/" "$GRUB_FILE"
    else
        sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\)\"\"/\1\"$MITIGATIONS_PARAMS\"/" "$GRUB_FILE"
    fi
    
    print_status "Configuração otimizada aplicada"
}

# Função para atualizar GRUB
update_grub() {
    print_status "Atualizando configuração do GRUB..."
    
    # Detectar se é BIOS ou UEFI
    if [ -d /sys/firmware/efi ]; then
        update-grub
    else
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
    
    # Alternativa para Ubuntu/Debian
    if command -v update-grub &> /dev/null; then
        update-grub
    elif command -v grub2-mkconfig &> /dev/null; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
    fi
    
    print_status "GRUB atualizado com sucesso!"
}

# Função para mostrar aviso de segurança
show_warning() {
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    ⚠️  AVISO DE SEGURANÇA ⚠️              ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║ Desativar mitigações torna seu sistema vulnerável a:     ║"
    echo "║ • Spectre, Meltdown, MDS, ZombieLoad, etc.               ║"
    echo "║ • Ataques side-channel                                   ║"
    echo "║ • Vazamento de informações sensíveis                     ║"
    echo "║                                                          ║"
    echo "║ Use apenas em:                                           ║"
    echo "║ • Sistemas isolados da internet                          ║"
    echo "║ • Benchmarks temporários                                 ║"
    echo "║ • Máquinas de laboratório/testes                         ║"
    echo "║                                                          ║"
    echo "║ Você assume TODA responsabilidade pelos riscos!          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    
    read -p "Você entende os riscos e deseja continuar? (s/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Operação cancelada pelo usuário."
        exit 0
    fi
}

# Função para menu principal
show_menu() {
    echo ""
    echo "========================================"
    echo "  DESATIVAR MITIGAÇÕES DE PROCESSADOR"
    echo "========================================"
    echo ""
    check_current_mitigations
    echo ""
    echo "Selecione uma opção:"
    echo "1) Desativar TODAS as mitigações (máximo desempenho)"
    echo "2) Configuração otimizada (recomendado para benchmarks)"
    echo "3) Restaurar configurações padrão (recomendado para segurança)"
    echo "4) Verificar estado atual"
    echo "5) Sair"
    echo ""
    read -p "Opção [1-5]: " option
    
    case $option in
        1)
            show_warning
            create_backup
            apply_mitigations_off
            update_grub
            print_status "Configuração completa! Reinicie o sistema."
            ;;
        2)
            show_warning
            create_backup
            apply_optimized_mitigations
            update_grub
            print_status "Configuração otimizada aplicada! Reinicie o sistema."
            ;;
        3)
            restore_default
            ;;
        4)
            check_current_mitigations
            print_status "Parâmetros atuais do GRUB:"
            grep "GRUB_CMDLINE_LINUX" "$GRUB_FILE"
            ;;
        5)
            print_status "Saindo..."
            exit 0
            ;;
        *)
            print_status "Opção inválida!"
            ;;
    esac
}

# Função para restaurar configurações padrão
restore_default() {
    print_status "Restaurando configurações padrão de segurança..."
    
    if [ -f "$GRUB_BACKUP" ]; then
        cp "$GRUB_BACKUP" "$GRUB_FILE"
        print_status "Configuração original restaurada de: $GRUB_BACKUP"
    else
        # Remover parâmetros de mitigação
        sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)mitigations=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
        sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)mitigations=[^ ]*\(.*"\)/\1\2/' "$GRUB_FILE"
        sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)nospec_store_bypass_disable\(.*"\)/\1\2/' "$GRUB_FILE"
        sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)nospec_store_bypass_disable\(.*"\)/\1\2/' "$GRUB_FILE"
        sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)no_stf_barrier\(.*"\)/\1\2/' "$GRUB_FILE"
        sed -i 's/\(GRUB_CMDLINE_LINUX=".*\)no_stf_barrier\(.*"\)/\1\2/' "$GRUB_FILE"
        print_status "Parâmetros de mitigação removidos"
    fi
    
    update_grub
    print_status "Configurações de segurança restauradas! Reinicie o sistema."
}

# Função para benchmark rápido
quick_benchmark() {
    print_status "Executando benchmark rápido (pode levar 30 segundos)..."
    
    # Teste simples de CPU
    echo "Benchmark de CPU (10 iterações de cálculo):"
    time for i in {1..10}; do
        echo "scale=5000; 4*a(1)" | bc -l -q > /dev/null
    done 2>&1 | grep real
    
    # Teste de syscall
    echo -e "\nBenchmark de syscall:"
    time for i in {1..10000}; do
        getent passwd root > /dev/null
    done 2>&1 | grep real
}

# Execução principal
main() {
    echo "Script de configuração de mitigações de CPU"
    echo "Sistema detectado: $(uname -a)"
    
    # Verificar se é Ubuntu
    if ! grep -qi "ubuntu" /etc/os-release; then
        print_status "Aviso: Este script foi testado no Ubuntu, mas deve funcionar em outras distribuições baseadas em Debian."
    fi
    
    show_menu
    
    # Oferecer benchmark
    echo ""
    read -p "Deseja executar um benchmark rápido antes de reiniciar? (s/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        quick_benchmark
    fi
    
    echo ""
    echo "══════════════════════════════════════════════════════════"
    echo "⚠️  REINICIE O SISTEMA PARA APLICAR AS ALTERAÇÕES!"
    echo "Comando: sudo reboot"
    echo "Para verificar após reinício: cat /sys/devices/system/cpu/vulnerabilities/*"
    echo "══════════════════════════════════════════════════════════"
}

# Executar
main