# 📋 To-Do List

> Ordem recomendada de execução. Cada etapa só começa quando a anterior termina (exceto onde indicado "paralelo").

---

## ✅ Já feito

- [x] NPC com movimento diagonal
- [x] Segunda skin de NPC (`oNpc2`)

## 1️⃣ Limpeza de dívida técnica
*(rápido, abre caminho pra tudo)*

- [X] Remover as 5 fases mockup do `oSeletorDeFases/Create_0.gml`
- [ ] Remover tecla debug `I` (incrementa comida) de `oController/Step_0.gml`
- [ ] Definir nomes finais das fases (`fase_nomes` / `fase_subtitulos`)

## 2️⃣ Tela de Vitória + Settings (base)
*(pré-requisito de 3, 4 e 6)*

- [X] Implementar `GUIA_VITORIA_E_SETTINGS.md`
  - Botão "Próxima Fase" na vitória + tela de Settings com reset de progresso

## 3️⃣ Áudio
*(adiciona controles de volume ao Settings)*

- [ ] Implementar `GUIA_AUDIO_E_MUSICA.md`
  - BGM via `oMusicManager` persistente + 15 SFX + step bar de volume

## 4️⃣ Settings extras
*(estende o Settings da etapa 2)*

- [ ] Implementar `GUIA_SETTINGS_EXTRA.md`
  - Fullscreen + Mostrar FPS + Idioma PT/EN

## 5️⃣ Conteúdo — 10 fases
*(pode rodar em paralelo a partir da etapa 2)*

- [ ] Tutorial — `GUIA_FASE_TUTORIAL.md`
- [ ] 9 fases (Fácil ×3, Médio ×4, Difícil ×2) — `GUIA_CRIACAO_DE_FASES.md`

## 6️⃣ Polish visual

- [ ] Lobisomem reativo no menu — `GUIA_LOBO_MENU_REATIVO.md`
- [ ] Sistema de estrelas na vitória — `GUIA_SISTEMA_DE_ESTRELAS.md`

---


> **Por que essa ordem?**
> Limpeza (1) primeiro pra não testar com lixo. Settings (2) é base de 3, 4 e 6. Áudio (3) e Settings extras (4) ambos extendem o Settings — fazer em ordem evita conflito de merge. Conteúdo (5) é desacoplado e pode rodar em paralelo desde a etapa 2. Polish (6) por último porque o sistema de estrelas precisa da Vitória pronta e o lobo reativo é puro visual.
