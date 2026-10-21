#!/bin/bash
# Actualiza TPM_VERSION en el .cfg que corresponde

set -euo pipefail

BASE_DIR="/usr"
TPM_V1="7.85.4555.0"
TPM_V2="7.86.19393.2"

# ───────────────────
# 1. Leer FRU jeje
# ───────────────────
echo "[*] Leyendo FRU del servidor... :D"
FRU_OUTPUT=$(ipmitool fru 2>/dev/null) || {
    echo "[ERROR] No se pudo ejecutar ipmitool fru."
    exit 1
}

# Guardamos info, cabiar grep si es diferente el fru al ejecutar ipmitool
BOARD_MFG=$(echo "$FRU_OUTPUT" | grep "Board Mfg   " | awk -F': ' '{print $2}' | tr -d '[:space:]')
BOARD_PN=$(echo "$FRU_OUTPUT" | grep "Board Part Number" | awk -F': ' '{print $2}' | tr -d '[:space:]')

echo "[*] Board Mfg detectado    : $BOARD_MFG"
echo "[*] Board Part Number      : $BOARD_PN"

# ─────────────────────────────────────────────────
# 2. Carpeta FBT Board Part Number correspondiente
# ─────────────────────────────────────────────────
case "$BOARD_PN" in
    *-001) FBT_FOLDER="Foxconn-FBT2_001" ;;
    *-002) FBT_FOLDER="Foxconn-FBT2_002" ;;
    *)
        echo "[ERROR] Board Part Number no reconocido: $BOARD_PN"
        exit 1
        ;;
esac

# ─────────────────────────
# 3. SKU según Board Mfg
# ─────────────────────────
case "$BOARD_MFG" in
    039) SKU_FILE="BU_sku_039.cfg" ;;
    042) SKU_FILE="BU_sku_042.cfg" ;;
    *)
        echo "[ERROR] Board Mfg no reconocido: $BOARD_MFG"
        exit 1
        ;;
esac

CFG_PATH="$BASE_DIR/$FBT_FOLDER/cfg/$SKU_FILE"

if [[ ! -f "$CFG_PATH" ]]; then
    echo "[ERROR] Archivo no encontrado: $CFG_PATH"
    exit 1
fi

echo "[*] Archivo objetivo        : $CFG_PATH"
echo ""

# ──────────────────────────────────────────────
# 4. Menú TPM
# ──────────────────────────────────────────────
echo "¿Qué versión de TPM quieres configurar?"
echo "  1) $TPM_V1"
echo "  2) $TPM_V2"
read -rp "Selección [1/2]: " TPM_SEL

case "$TPM_SEL" in
    1) NEW_TPM="$TPM_V1" ;;
    2) NEW_TPM="$TPM_V2" ;;
    *)
        echo "[ERROR] Opción inválida."
        exit 1
        ;;
esac

# ──────────────────────────────────────────────
# 5. Aplicar el cambio
# ──────────────────────────────────────────────
CURRENT_TPM=$(grep "^TPM_VERSION=" "$CFG_PATH" | cut -d'"' -f2)

if [[ "$CURRENT_TPM" == "$NEW_TPM" ]]; then
    echo "[INFO] Ya tiene TPM_VERSION=\"$NEW_TPM\". Sin cambios."
    exit 0
fi

cp "$CFG_PATH" "${CFG_PATH}.bak"
sed -i "s/^TPM_VERSION=.*/TPM_VERSION=\"$NEW_TPM\"/" "$CFG_PATH"

echo ""
echo "Listo :D"
echo "    Antes : $CURRENT_TPM"
echo "    Ahora : $NEW_TPM"
echo "    Backup: ${CFG_PATH}.bak"

echo "APAGANDO UNIDAD!!!"
sleep 2
echo "=>               |"
sleep 0.2
echo "==>              |"
sleep 0.2
echo "===>             |"
sleep 0.2
echo "====>            |"
sleep 0.2
echo "=====>           |"
sleep 0.2
echo "======>          |"
sleep 0.2
echo "=======>         |"
sleep 0.2
echo "========>        |"
sleep 0.2
echo "=========>       |"
sleep 0.2
echo "==========>      |"
sleep 0.2
echo "===========>     |"
sleep 0.2
echo "============>    |"
sleep 0.2
echo "=============>   |"
sleep 0.2
echo "==============>  |"
sleep 0.2
echo "===============> |"
sleep 0.2
echo "================>|"
sleep 0.2
poweroff

