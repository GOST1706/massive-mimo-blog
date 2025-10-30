---
title: "Mini Caso Técnico: Eficiencia Espectral en Massive MIMO"
authors: [jaiver, julian, michel]
categories: [Simulación]
---

Para ilustrar de forma práctica el potencial del Massive MIMO, se plantea un **mini-caso técnico** de simulación orientado al análisis de eficiencia espectral en el enlace ascendente (uplink).

### 🎯 Objetivo
Evaluar cómo cambia la **eficiencia espectral promedio por usuario** al variar:
- El número de antenas en la estación base (N = 16, 64, 128)
- El nivel de contaminación de pilotos entre celdas vecinas

### 🧮 Metodología
1. Modelar un canal de **Rayleigh plano** en un sistema TDD.
2. Generar señales piloto para cada usuario y aplicar estimación LS (mínimos cuadrados).
3. Reutilizar las secuencias piloto en dos celdas adyacentes para simular contaminación.
4. Calcular el **SINR** y la **eficiencia espectral (SE = log₂(1 + SINR))** promedio.
5. Comparar los resultados variando N y el nivel de interferencia.

### 📈 Resultados esperados
- A mayor número de antenas, mejora la eficiencia espectral.
- El aumento de contaminación de pilotos degrada notablemente el desempeño.
- Con N = 128 antenas y mínima interferencia, la SE puede duplicarse respecto al caso N = 16.

### 🔍 Conclusión
Este caso evidencia cómo **Massive MIMO logra mayor capacidad mediante ganancia de diversidad espacial**, aunque su rendimiento depende críticamente del control de interferencias y la estimación precisa del canal.
