#!/bin/bash
# Actualiza BMC_DRAM en el .cfg que corresponde

set -euo pipefail

BASE_DIR="/usr"

# ───────────────────
# 1. Leer FRU jeje
# ───────────────────
echo "[*] Leyendo FRU del servidor... :D"
FRU_OUTPUT=$(ipmitool fru 2>/dev/null) || {
    echo "[ERROR] No se pudo ejecutar ipmitool fru."
    exit 1
}

BOARD_MFG=$(echo "$FRU_OUTPUT" | grep "Board Mfg   " | awk -F': ' '{print $2}' | tr -d '[:space:]')
BOARD_PN=$(echo "$FRU_OUTPUT" | grep "Board Part Number" | awk -F': ' '{print $2}' | tr -d '[:space:]')

echo "[*] Board Mfg detectado    : $BOARD_MFG"
echo "[*] Board Part Number      : $BOARD_PN"

# ─────────────────────────────────────────────────
# 2. Carpeta FBT Board Part Number Correspondiente
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
# 4. Menú DRAM
# ──────────────────────────────────────────────
echo "¿Qué valor de BMC_DRAM necesitas?"
echo "  1) 512"
echo "  2) 965"
read -rp "Selección [1/2]: " DRAM_SEL

case "$DRAM_SEL" in
    1) NEW_DRAM="512" ;;
    2) NEW_DRAM="965" ;;
    *)
        echo "[ERROR] Opción inválida."
        exit 1
        ;;
esac

# ──────────────────────────────────────────────
# 5. Aplicar el cambio
# ──────────────────────────────────────────────
CURRENT_DRAM=$(grep "^BMC_DRAM=" "$CFG_PATH" | cut -d'"' -f2)

if [[ "$CURRENT_DRAM" == "$NEW_DRAM" ]]; then
    echo "[INFO] Ya tiene BMC_DRAM=\"$NEW_DRAM\". Sin cambios."
    exit 0
fi

cp "$CFG_PATH" "${CFG_PATH}.bak"
sed -i "s/^BMC_DRAM=.*/BMC_DRAM=\"$NEW_DRAM\"/" "$CFG_PATH"

echo ""
echo "Listo :D"
echo "    Antes : $CURRENT_DRAM"
echo "    Ahora : $NEW_DRAM"
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
#poweroff