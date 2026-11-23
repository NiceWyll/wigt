# Cómo obtener el IPA de Wigt con Codemagic e instalarlo con Sideloadly

> Sin Mac, sin cuenta de pago de Apple. Solo necesitas tu Apple ID normal.

---

## Requisitos

| Herramienta | Dónde conseguirla | Coste |
|---|---|---|
| Cuenta GitHub (privada) | github.com | Gratis |
| Cuenta Codemagic | codemagic.io | Gratis (500 min/mes) |
| Sideloadly (Windows) | sideloadly.io | Gratis |
| iTunes (Windows) | microsoft.com/store | Gratis |
| Tu iPhone | — | Ya lo tienes |
| Tu Apple ID | account.apple.com | Gratis |

---

## Paso 1 — Subir el código a GitHub

### 1.1 Crear repositorio privado
1. Ve a [github.com/new](https://github.com/new)
2. Nombre: `wigt`
3. Visibilidad: **Private** (importante — es tu código personal)
4. **NO** marques "Initialize repository"
5. Haz clic en **Create repository**

### 1.2 Inicializar Git y subir desde tu PC

Abre la terminal de Android Studio (o PowerShell) y ejecuta:

```powershell
Set-Location "C:\Users\LENOVO\.gemini\antigravity\scratch\wigt"

# Inicializar git
git init
git add .
git commit -m "feat: Wigt app inicial (Fases 0-8)"

# Conectar con tu repositorio (cambia TU_USUARIO por tu usuario de GitHub)
git remote add origin https://github.com/TU_USUARIO/wigt.git
git branch -M main
git push -u origin main
```

> Si es la primera vez que usas Git, puede pedir tu usuario y contraseña de GitHub.
> Usa un **Personal Access Token** como contraseña (GitHub > Settings > Developer settings > Tokens).

---

## Paso 2 — Conectar Codemagic

1. Ve a [codemagic.io](https://codemagic.io) y crea una cuenta (con GitHub es directo)
2. Haz clic en **Add application**
3. Selecciona **GitHub** y autoriza el acceso
4. Busca y selecciona el repositorio `wigt`
5. Cuando pregunte el tipo de proyecto, elige **Flutter App**
6. Codemagic detectará el archivo `codemagic.yaml` automáticamente

---

## Paso 3 — Configurar firma para iOS (firma personal)

Codemagic necesita un certificado para firmar el IPA. Para Sideloadly usamos **firma sin certificado** (unsigned), que Sideloadly re-firma con tu Apple ID al instalar.

El workflow `ios-sideloadly` en `codemagic.yaml` ya está configurado para **compilar sin firma** (`--no-codesign`) y empaquetar el `.ipa` directamente.

> **No necesitas pagar la cuenta de desarrollador de Apple (\$99/año)** para usar Sideloadly.
> Sideloadly usa tu Apple ID gratuito para re-firmar e instalar.

---

## Paso 4 — Lanzar el build

1. En Codemagic, abre tu app `wigt`
2. Ve a la pestaña **Builds**
3. Selecciona el workflow **"iOS — IPA para Sideloadly"**
4. Haz clic en **Start new build**
5. Espera ~15-25 minutos (el primer build tarda más)
6. Cuando termine, descarga el archivo **`Wigt.ipa`**

> Codemagic te manda un e-mail cuando termina el build.

---

## Paso 5 — Instalar en tu iPhone con Sideloadly

### 5.1 Instalar Sideloadly
1. Ve a [sideloadly.io](https://sideloadly.io) y descarga la versión Windows
2. Instálalo normalmente

### 5.2 Instalar iTunes (necesario para que Sideloadly reconozca el iPhone)
1. Descarga iTunes desde [Microsoft Store](https://apps.microsoft.com/store/detail/itunes/9PB2MZ1ZMB1S) o apple.com
2. Ábrelo al menos una vez

### 5.3 Conectar iPhone y confiar en la PC
1. Conecta tu iPhone con el cable USB
2. En el iPhone aparecerá "¿Confiar en esta computadora?" → toca **Confiar**
3. Abre iTunes — debe aparecer tu iPhone

### 5.4 Instalar el IPA con Sideloadly
1. Abre Sideloadly
2. Tu iPhone debe aparecer en la lista de dispositivos
3. Arrastra el archivo `Wigt.ipa` al área central de Sideloadly
4. Ingresa tu Apple ID (el de iCloud)
5. Ingresa tu contraseña de Apple ID
   > Sideloadly puede pedir un código de verificación de 2FA — revisa tu iPhone
6. Haz clic en **Start**
7. Espera ~2-3 minutos
8. En tu iPhone ve a: **Ajustes → General → VPN y administración de dispositivos**
9. Busca tu Apple ID y toca **Confiar**
10. Abre Wigt desde la pantalla de inicio

---

## Limitaciones de Sideloadly (Apple ID gratuito)

| Límite | Detalle |
|---|---|
| **7 días** | La app expira cada 7 días — hay que re-instalar con Sideloadly |
| **3 apps** | Máximo 3 apps sideloaded al mismo tiempo con Apple ID gratuito |
| **Sin notificaciones push** | No aplica (Wigt usa notificaciones locales, no push) |
| **Sin iCloud** | No aplica (Wigt es 100% local) |

> **Truco**: Sideloadly tiene una opción "Auto re-sign" para renovar automáticamente antes de los 7 días si dejas el iPhone conectado.

---

## Solución de problemas comunes

| Problema | Solución |
|---|---|
| "iPhone no aparece en Sideloadly" | Instala iTunes, reconecta cable, toca Confiar en iPhone |
| "Error de firma / certificado" | El IPA ya es unsigned — Sideloadly lo firma él solo; revisa que pusiste bien el Apple ID |
| "App se cierra al abrir" | Falta el paso de Confiar en Ajustes → VPN y administración |
| "Build falla en Codemagic" | Revisa los logs en la pestaña Builds; el error más común es falta de CocoaPods |
| "Expiró la app a los 7 días" | Repite el paso 5.4 (Sideloadly) — no necesitas re-descargar el IPA |

---

## Flujo completo resumido

```
Código en tu PC (Windows)
        ↓ git push
GitHub (repo privado)
        ↓ Codemagic lo detecta
Mac virtual en Codemagic
        ↓ flutter build ios --no-codesign
Wigt.ipa (sin firma)
        ↓ descarga
Tu PC Windows
        ↓ Sideloadly + tu Apple ID
iPhone → Wigt instalado ✓
```

