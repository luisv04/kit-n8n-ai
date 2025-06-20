#!/bin/ash

echo "=== Iniciando importación automática de n8n ==="

# Esperar a que n8n esté completamente listo
echo "Esperando a que n8n esté disponible..."
for i in $(seq 1 30); do
    if wget --quiet --tries=1 --spider http://n8n:5678/ 2>/dev/null; then
        echo "n8n está listo!"
        break
    fi
    echo "Esperando... ($i/30)"
    sleep 2
done

# Verificar que los directorios existen
if [ ! -d "/data/credentials" ]; then
    echo "❌ Directorio /data/credentials no encontrado"
    exit 1
fi

if [ ! -d "/data/workflows" ]; then
    echo "❌ Directorio /data/workflows no encontrado"
    exit 1
fi

# Contar archivos
cred_count=$(find /data/credentials -name "*.json" | wc -l)
workflow_count=$(find /data/workflows -name "*.json" | wc -l)

echo "📁 Archivos encontrados:"
echo "   - Credenciales: $cred_count"
echo "   - Workflows: $workflow_count"

# Importar credenciales si existen
if [ $cred_count -gt 0 ]; then
    echo "🔑 Importando credenciales..."
    if n8n import:credentials --separate --input=/data/credentials; then
        echo "✅ Credenciales importadas exitosamente"
    else
        echo "❌ Error importando credenciales"
    fi
else
    echo "ℹ️  No se encontraron credenciales para importar"
fi

# Importar workflows si existen
if [ $workflow_count -gt 0 ]; then
    echo "⚡ Importando workflows..."
    # Importar cada workflow individualmente para evitar errores
    for workflow_file in /data/workflows/*.json; do
        if [ -f "$workflow_file" ]; then
            echo "   Importando: $(basename "$workflow_file")"
            if n8n import:workflow --input="$workflow_file"; then
                echo "   ✅ $(basename "$workflow_file") importado"
            else
                echo "   ❌ Error importando $(basename "$workflow_file")"
            fi
        fi
    done
else
    echo "ℹ️  No se encontraron workflows para importar"
fi

echo "=== Importación automática completada ===" 